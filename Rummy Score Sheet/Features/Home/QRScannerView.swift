//
//  QRScannerView.swift
//  Rummy Scorekeeper
//
//  Camera-based QR code scanner for joining rooms
//

import AVFoundation
import SwiftUI

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    let onCodeScanned: (String) -> Void

    @State private var cameraPermission: CameraPermission = .unknown
    @State private var scannedCode: String?

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppTheme.background)
                .ignoresSafeArea()

            switch cameraPermission {
            case .authorized:
                CameraPreviewView(onCodeScanned: { code in
                    guard scannedCode == nil else { return }
                    scannedCode = code
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onCodeScanned(code)
                    dismiss()
                })
                .ignoresSafeArea()

                viewfinderOverlay
            case .denied:
                permissionDeniedView
            case .unknown:
                permissionRequestingView
            }
        }
        .onAppear {
            checkCameraPermission()
        }
    }

    private var viewfinderOverlay: some View {
        RoundedRectangle(cornerRadius: AppRadius.xl)
            .stroke(AppTheme.primaryColor, lineWidth: 3)
            .padding(AppSpacing._8)
            .aspectRatio(1, contentMode: .fit)
    }

    private var permissionRequestingView: some View {
        VStack(spacing: AppSpacing._4) {
            ProgressView()
                .tint(AppTheme.primaryColor)
                .scaleEffect(1.5)
            Text("Requesting camera access...")
                .font(AppTypography.body())
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: AppSpacing._6) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.textTertiary)
            Text("Camera Access Required")
                .font(AppTypography.title2())
                .foregroundStyle(AppTheme.textPrimary)
            Text("Please enable camera access in Settings to scan QR codes.")
                .font(AppTypography.body())
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(AppTypography.headline())
            .foregroundStyle(AppTheme.primaryColor)
        }
        .padding()
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermission = .authorized
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermission = granted ? .authorized : .denied
                }
            }
        default:
            cameraPermission = .denied
        }
    }
}

private enum CameraPermission {
    case unknown
    case authorized
    case denied
}

private struct CameraPreviewView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc = QRScannerViewController()
        vc.onCodeScanned = onCodeScanned
        return vc
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

private class QRScannerViewController: UIViewController {
    var onCodeScanned: ((String) -> Void)?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession?.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)

        captureSession = session
        previewLayer = layer
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let qrObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = qrObject.stringValue,
              !stringValue.isEmpty else { return }
        let code = String(stringValue.uppercased().prefix(6))
        onCodeScanned?(code)
    }
}
