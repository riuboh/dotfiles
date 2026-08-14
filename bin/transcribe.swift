// macOS 26+ の Speech フレームワークでローカル文字起こしを行う。
// 音声/動画ファイルを受け取り、同じ場所に .txt を書き出す。
// ビルドは bin/transcribe（ラッパー）が自動で行う。

import AVFoundation
import Foundation
import Speech

@main
struct Transcribe {
    static func main() async {
        do {
            try await run()
        } catch {
            FileHandle.standardError.write("error: \(error.localizedDescription)\n".data(using: .utf8)!)
            exit(1)
        }
    }

    static func run() async throws {
        let args = Array(CommandLine.arguments.dropFirst())
        guard let inputPath = args.first, !inputPath.hasPrefix("-") else {
            FileHandle.standardError.write("usage: transcribe <audio-or-video-file> [--locale ja-JP]\n".data(using: .utf8)!)
            exit(2)
        }
        var localeID = "ja-JP"
        var i = 1
        while i < args.count {
            if args[i] == "--locale", i + 1 < args.count {
                localeID = args[i + 1]
                i += 2
            } else {
                i += 1
            }
        }

        let url = URL(fileURLWithPath: inputPath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw Fail("ファイルが見つかりません: \(url.path)")
        }

        let transcriber = try await makeTranscriber(localeID: localeID)
        let analyzer = SpeechAnalyzer(modules: [transcriber])
        guard let analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else {
            throw Fail("対応する音声フォーマットを取得できませんでした")
        }

        let (stream, continuation) = AsyncStream<AnalyzerInput>.makeStream()
        let resultsTask = Task { () -> [String] in
            var lines: [String] = []
            for try await result in transcriber.results where result.isFinal {
                let line = String(result.text.characters).trimmingCharacters(in: .whitespacesAndNewlines)
                if !line.isEmpty { lines.append(line) }
            }
            return lines
        }

        try await analyzer.start(inputSequence: stream)
        do {
            try await feed(url: url, format: analyzerFormat, into: continuation)
        } catch {
            continuation.finish()
            throw error
        }
        continuation.finish()
        try await analyzer.finalizeAndFinishThroughEndOfInput()

        let lines = try await resultsTask.value
        let outURL = url.deletingPathExtension().appendingPathExtension("txt")
        try (lines.joined(separator: "\n") + "\n").write(to: outURL, atomically: true, encoding: .utf8)
        print(outURL.path)
    }

    /// 指定ロケールの SpeechTranscriber を用意する。モデル未導入なら取得を試みる。
    static func makeTranscriber(localeID: String) async throws -> SpeechTranscriber {
        let requested = Locale(identifier: localeID)
        let supported = await SpeechTranscriber.supportedLocales
        guard let locale = match(requested, in: supported) else {
            let names = supported.map { $0.identifier(.bcp47) }.sorted().joined(separator: ", ")
            throw Fail("ロケール \(localeID) は非対応です。利用可能: \(names)")
        }

        let transcriber = SpeechTranscriber(
            locale: locale,
            transcriptionOptions: [],
            reportingOptions: [],
            attributeOptions: []
        )

        let installed = await SpeechTranscriber.installedLocales
        if match(locale, in: installed) == nil {
            FileHandle.standardError.write("\(locale.identifier(.bcp47)) のモデルを取得しています...\n".data(using: .utf8)!)
            if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                try await request.downloadAndInstall()
            }
        }
        return transcriber
    }

    static func match(_ locale: Locale, in pool: some Sequence<Locale>) -> Locale? {
        let target = locale.identifier(.bcp47)
        if let exact = pool.first(where: { $0.identifier(.bcp47) == target }) { return exact }
        guard let language = locale.language.languageCode?.identifier else { return nil }
        return pool.first { $0.language.languageCode?.identifier == language }
    }

    /// AVAssetReader で音声トラックを読み、解析器が求める形式に整えて流し込む。
    /// AVAudioFile と違い、映像トラックを含む mp4/mov も同じ経路で扱える。
    static func feed(
        url: URL,
        format analyzerFormat: AVAudioFormat,
        into continuation: AsyncStream<AnalyzerInput>.Continuation
    ) async throws {
        let asset = AVURLAsset(url: url)
        guard let track = try await asset.loadTracks(withMediaType: .audio).first else {
            throw Fail("音声トラックが見つかりません: \(url.lastPathComponent)")
        }

        // 解析器の要求形式に極力そろえて読み出し、変換の手間を省く。
        let isFloat = analyzerFormat.commonFormat == .pcmFormatFloat32
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: analyzerFormat.sampleRate,
            AVNumberOfChannelsKey: Int(analyzerFormat.channelCount),
            AVLinearPCMBitDepthKey: isFloat ? 32 : 16,
            AVLinearPCMIsFloatKey: isFloat,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false,
        ]
        guard let readFormat = AVAudioFormat(
            commonFormat: isFloat ? .pcmFormatFloat32 : .pcmFormatInt16,
            sampleRate: analyzerFormat.sampleRate,
            channels: analyzerFormat.channelCount,
            interleaved: true
        ) else {
            throw Fail("読み出しフォーマットを構築できませんでした")
        }

        let reader = try AVAssetReader(asset: asset)
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        output.alwaysCopiesSampleData = false
        guard reader.canAdd(output) else { throw Fail("音声トラックを読み出せません") }
        reader.add(output)
        guard reader.startReading() else {
            throw Fail(reader.error?.localizedDescription ?? "読み出しを開始できませんでした")
        }

        // 解析器は入力バッファに analyzerFormat そのものが付いていることを期待する。
        // モノラルならインターリーブの区別が無く読み出し結果と同一レイアウトなので、
        // analyzerFormat を直接まとわせて変換を省く。多チャンネル時のみ変換を挟む。
        let direct = analyzerFormat.channelCount == 1
        let bufferFormat = direct ? analyzerFormat : readFormat
        let converter = direct ? nil : AVAudioConverter(from: readFormat, to: analyzerFormat)

        while let sample = output.copyNextSampleBuffer() {
            defer { CMSampleBufferInvalidate(sample) }
            guard let buffer = pcmBuffer(from: sample, format: bufferFormat) else { continue }
            if let converter {
                guard let converted = convert(buffer, with: converter, to: analyzerFormat) else { continue }
                continuation.yield(AnalyzerInput(buffer: converted))
            } else {
                continuation.yield(AnalyzerInput(buffer: buffer))
            }
        }

        if reader.status == .failed {
            throw Fail(reader.error?.localizedDescription ?? "読み出しに失敗しました")
        }
    }

    static func pcmBuffer(from sample: CMSampleBuffer, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let frames = CMSampleBufferGetNumSamples(sample)
        guard frames > 0,
              let blockBuffer = CMSampleBufferGetDataBuffer(sample),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frames))
        else { return nil }

        // mDataByteSize は frameLength に連動するため、コピー前に長さを確定させる。
        buffer.frameLength = AVAudioFrameCount(frames)
        guard let dest = buffer.mutableAudioBufferList.pointee.mBuffers.mData else { return nil }

        let byteCount = min(
            CMBlockBufferGetDataLength(blockBuffer),
            Int(buffer.mutableAudioBufferList.pointee.mBuffers.mDataByteSize))
        let status = CMBlockBufferCopyDataBytes(
            blockBuffer, atOffset: 0, dataLength: byteCount, destination: dest)
        guard status == kCMBlockBufferNoErr else { return nil }
        return buffer
    }

    static func convert(
        _ buffer: AVAudioPCMBuffer,
        with converter: AVAudioConverter,
        to format: AVAudioFormat
    ) -> AVAudioPCMBuffer? {
        let ratio = format.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 1024
        guard let out = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else { return nil }
        var supplied = false
        var error: NSError?
        converter.convert(to: out, error: &error) { _, status in
            if supplied {
                status.pointee = .noDataNow
                return nil
            }
            supplied = true
            status.pointee = .haveData
            return buffer
        }
        guard error == nil, out.frameLength > 0 else { return nil }
        return out
    }
}

struct Fail: LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}
