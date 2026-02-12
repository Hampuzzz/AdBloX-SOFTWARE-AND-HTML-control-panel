import SwiftUI
import AVFoundation

/// Setup flow: scan QR code from your AdBloX device, or enter IP manually.
/// This is shown on first launch or when tapping the + button.
struct DeviceSetupView: View {
    @EnvironmentObject var vpn: VPNManager
    @Environment(\.dismiss) var dismiss
    @State private var manualIP: String = ""
    @State private var deviceName: String = ""
    @State private var showScanner = false
    @State private var scanResult: String?
    @State private var setupDone = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.adbloxBg.ignoresSafeArea()

                if setupDone {
                    // Success
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.adbloxGreen)

                        Text("Device Connected!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        VStack(spacing: 4) {
                            Text(vpn.deviceName)
                                .font(.headline)
                                .foregroundColor(.adbloxText)
                            Text(vpn.deviceIP)
                                .font(.system(.callout, design: .monospaced))
                                .foregroundColor(.adbloxMuted)
                        }

                        Text("Tap Connect on the main screen to tunnel\nall traffic through your AdBloX device.")
                            .font(.subheadline)
                            .foregroundColor(.adbloxMuted)
                            .multilineTextAlignment(.center)

                        Button(action: { dismiss() }) {
                            Text("Done")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.adbloxCyan)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 32) {
                            // QR Scanner option
                            VStack(spacing: 16) {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 48))
                                    .foregroundColor(.adbloxCyan)

                                Text("Scan QR Code")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text("Your AdBloX device shows a QR code\nin its setup screen or dashboard.")
                                    .font(.caption)
                                    .foregroundColor(.adbloxMuted)
                                    .multilineTextAlignment(.center)

                                Button(action: { showScanner = true }) {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                        Text("Open Scanner")
                                    }
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.adbloxCyan)
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.adbloxCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.adbloxBorder, lineWidth: 1)
                            )
                            .cornerRadius(16)

                            // Divider
                            HStack {
                                Rectangle().fill(Color.adbloxBorder).frame(height: 1)
                                Text("OR")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.adbloxMuted)
                                Rectangle().fill(Color.adbloxBorder).frame(height: 1)
                            }

                            // Manual IP entry
                            VStack(spacing: 16) {
                                Text("Enter IP Manually")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Device IP Address")
                                        .font(.caption)
                                        .foregroundColor(.adbloxMuted)
                                    TextField("e.g. 100.64.0.1 or 192.168.1.100", text: $manualIP)
                                        .font(.system(.body, design: .monospaced))
                                        .padding()
                                        .background(Color.adbloxCard)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.adbloxBorder, lineWidth: 1)
                                        )
                                        .foregroundColor(.adbloxText)
                                        .keyboardType(.decimalPad)
                                        .autocorrectionDisabled()
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Device Name (optional)")
                                        .font(.caption)
                                        .foregroundColor(.adbloxMuted)
                                    TextField("e.g. Living Room AdBloX", text: $deviceName)
                                        .padding()
                                        .background(Color.adbloxCard)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.adbloxBorder, lineWidth: 1)
                                        )
                                        .foregroundColor(.adbloxText)
                                        .autocorrectionDisabled()
                                }

                                Button(action: saveManual) {
                                    Text("Save Device")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            manualIP.isEmpty
                                                ? Color.adbloxMuted
                                                : Color.adbloxCyan
                                        )
                                        .cornerRadius(12)
                                }
                                .disabled(manualIP.isEmpty)
                            }
                            .padding()
                            .background(Color.adbloxCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.adbloxBorder, lineWidth: 1)
                            )
                            .cornerRadius(16)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Set Up Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.adbloxCyan)
                }
            }
            .sheet(isPresented: $showScanner) {
                QRScannerSheet(result: $scanResult)
            }
            .onChange(of: scanResult, perform: { newValue in
                guard let code = newValue else { return }
                handleScanResult(code)
            })
        }
    }

    private func saveManual() {
        let ip = manualIP.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ip.isEmpty else { return }
        vpn.configureDevice(ip: ip, name: deviceName)
        withAnimation { setupDone = true }
    }

    private func handleScanResult(_ code: String) {
        if let enrollment = vpn.parseEnrollment(code) {
            vpn.configureDevice(ip: enrollment.ip, name: enrollment.name)
            if !enrollment.key.isEmpty {
                UserDefaults.standard.set(enrollment.key, forKey: "adblox_auth_key")
            }
            withAnimation { setupDone = true }
        } else {
            // Try as plain IP
            vpn.configureDevice(ip: code, name: "AdBloX Device")
            withAnimation { setupDone = true }
        }
    }
}

// MARK: - QR Scanner

struct QRScannerSheet: View {
    @Binding var result: String?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.adbloxBg.ignoresSafeArea()
                QRCameraView(scannedCode: $result)
                    .cornerRadius(20)
                    .padding(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.adbloxCyan, lineWidth: 2)
                            .padding(32)
                    )

                VStack {
                    Spacer()
                    Text("Point at the QR code on your AdBloX device")
                        .font(.subheadline)
                        .foregroundColor(.adbloxMuted)
                        .padding(.bottom, 40)
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.adbloxCyan)
                }
            }
            .onChange(of: result, perform: { _ in dismiss() })
        }
    }
}

/// AVCaptureSession-based QR code scanner
struct QRCameraView: UIViewRepresentable {
    @Binding var scannedCode: String?

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        view.backgroundColor = UIColor(Color.adbloxCard)

        guard let device = AVCaptureDevice.default(for: .video) else {
            addLabel(to: view, "Camera not available.\nUse manual IP entry instead.")
            return view
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            let session = AVCaptureSession()
            session.addInput(input)

            let output = AVCaptureMetadataOutput()
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
            output.metadataObjectTypes = [.qr]

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.frame = view.bounds
            preview.videoGravity = .resizeAspectFill
            view.layer.addSublayer(preview)

            context.coordinator.session = session
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        } catch {
            addLabel(to: view, "Camera error: \(error.localizedDescription)")
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(scannedCode: $scannedCode) }

    private func addLabel(to view: UIView, _ text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.frame = view.bounds
        view.addSubview(label)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding var scannedCode: String?
        var session: AVCaptureSession?

        init(scannedCode: Binding<String?>) { _scannedCode = scannedCode }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = obj.stringValue else { return }
            scannedCode = value
            session?.stopRunning()
        }
    }
}
