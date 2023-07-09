//
//  ContentView.swift
//  arkit-experiment
//
//  Created by applejxd on 2023/07/09.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var cam_position: simd_float3 = simd_float3(0, 0, 0)
    
    var body: some View {
        VStack {
            // 画面をエッジまで拡張
            ARViewContainer(cam_position: $cam_position).edgesIgnoringSafeArea(.all)
            
//            LabelView(cam_position: $cam_position).padding()
            Text("(\(self.cam_position.x),\(self.cam_position.y),\(self.cam_position.z)").padding()
        }
    }
}

struct LabelView: UIViewRepresentable {
    @Binding var cam_position: simd_float3
    
    func makeUIView(context: Context) -> UILabel {
        let labelView:UILabel = UILabel()       // UIKitのビュー
        labelView.text = "0,0,0" // テキストを格納
        labelView.textAlignment = NSTextAlignment.center
        
        return labelView // ビューを返す
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = "(\(cam_position.x),\(cam_position.y),\(cam_position.z)"
    }
}

// AR 表示
// cf. https://www.ralfebert.com/ios/realitykit-dice-tutorial/
struct ARViewContainer: UIViewRepresentable {
    @Binding var cam_position: simd_float3
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        // delegate にユーザ定義の Coodinator を設定.
        // 後述の makeCoordinator と Coordinator を定義しないとエラー.
        arView.session.delegate = context.coordinator

        // トラッキング設定
        // cf. https://developer.apple.com/documentation/arkit/arworldtrackingconfiguration
        let config = ARWorldTrackingConfiguration()
        // 平面検知 ON
        config.planeDetection = [.horizontal]
        // LiDAR からのメッシュ生成 ON
        // .mesh はメッシュ判定のみ/.meshWithClassification は種別判定も実施
        // cf. https://www.toyship.org/2020/03/30/150924
        config.sceneReconstruction = .meshWithClassification
        
        // AR セッションを開始
        let session = arView.session
        session.run(config)

        #if DEBUG
        // デバッグ情報重畳表示 (原点・特徴点・メッシュ形状)
        // cf. https://developer.apple.com/documentation/realitykit/arview/debugoptions-swift.struct
        arView.debugOptions = [.showWorldOrigin, .showFeaturePoints, .showSceneUnderstanding]
        #endif
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.cam_position)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var cam_position: simd_float3
        
        init(_ cam_position: simd_float3) {
            self.cam_position = cam_position
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // cf. https://rockyshikoku.medium.com/get-the-location-of-the-device-with-arkit-4e4c54831fbc
            let transform: simd_float4 = frame.camera.transform.columns.3
            let devicePosition: simd_float3 = simd_float3(x: transform.x, y: transform.y, z: transform.z)
            self.cam_position = devicePosition
        }
    }
}

// デバッグ用に作成中の画面を Xcode で Preview 表示
#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
