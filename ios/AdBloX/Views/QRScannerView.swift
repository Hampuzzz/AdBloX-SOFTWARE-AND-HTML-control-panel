import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var tailscale: TailscaleManager
    @State private var scannedCode: String?
    @State private var isScanned = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.adbloxBackground.ignoresSafeArea()

                if isScanned, let code = scannedCode {
                    // Success state
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.adbloxSuccess)

                        Text("Device Enrolled!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Auth key received. Connecting to mesh...")
                            .font(.subheadline)
                            .foregroundColor(.adbloxTextMuted)
                            .multilineTextAlignment(.center)

                        Text(code)
                            .font(.caption)
                            .fontDesign(.monospaced)
                            .foregroundColor(.adbloxPrimary)
                            .padding()
                            .background(Color.adbloxCardBg)
                            .cornerRadius(8)

                        Button(action: { dismiss() }) {
                            Text("Done")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.adbloxPrimary)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                } else {
                    // Scanner
                    VStack(spacing: 24) {
                        QRCameraView(scannedCode: $scannedCode)
                            .frame(width: 280, height: 280)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.adbloxPrimary, lineWidth: 2)
                            )

                        Text("Point camera at the QR code\non the AdBloX dashboard")
                            .font(.subheadline)
                            .foregroundColor(.adbloxTextMuted)
                            .multilineTextAlignment(.center)

                        // Manual entry
                        VStack(spacing: 8) {
                            Text("Or enter auth key manually:")
                                .font(.caption)
                                .foregroundColor(.adbloxTextMuted)

                            HStack {
                                TextField("tskey-auth-...", text: Binding(
                                    get: { scannedCode ?? "" },
                                    set: { scannedCode = $0 }
                                ))
                                .font(.caption)
                                .fontDesign(.monospaced)
                                .padding(10)
                                .background(Color.adbloxCardBg)
                                .cornerRadius(8)
                                .foregroundColor(.adbloxText)

                                Button("Join") {
                                    if let code = scannedCode, !code.isEmpty {
                                        enrollDevice(code)
                                    }
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.adbloxPrimary)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.adbloxPrimary)
                }
            }
            .onChange(of: scannedCode) { newValue in
                if let code = newValue, code.starts(with: "https://mesh.adblox.se/join") {
                    enrollDevice(code)
                }
            }
        }
    }

    private func enrollDevice(_ code: String) {
        // Extract auth key from URL or use raw key
        var authKey = code
        if let url = URLComponents(string: code),
           let key = url.queryItems?.first(where: { $0.name == "key" })?.value {
            authKey = key
        }

        tailscale.enroll(authKey: authKey)
        isScanned = true
    }
}

/// Camera view for QR scanning using AVCaptureSession
struct QRCameraView: UIViewRepresentable {
    @Binding var scannedCode: String?

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 280))
        view.backgroundColor = UIColor(Color.adbloxCardBg)

        guard let device = AVCaptureDevice.default(for: .video) else {
            addPlaceholder(to: view, text: "Camera not available")
            return view
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            let session = AVCaptureSession()
            session.addInput(input)

            let output = AVCaptureMetadataOutput()
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }

            context.coordinator.session = session
        } catch {
            addPlaceholder(to: view, text: "Camera error")
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode)
    }

    private func addPlaceholder(to view: UIView, text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = .gray
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding var scannedCode: String?
        var session: AVCaptureSession?

        init(scannedCode: Binding<String?>) {
            _scannedCode = scannedCode
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = object.stringValue else { return }

            scannedCode = value
            session?.stopRunning()
        }
    }
}
