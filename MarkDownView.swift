//
//  MarkDownView.swift
//  DataNote
//
//  Created by Yang Xu on 2020/10/24.
//

import Foundation
import SwiftUI
import MarkdownView

struct MarkDownView:UIViewRepresentable{
    let filename:String
    let isScrollEnable:Bool
    let enableImage:Bool
    let imageParser:[MarkDownImageParser] // 前面的是md里面的imageName(临时的),后面的是bundle中的图片名称
    let proxy:GeometryProxy
    
    func makeUIView(context: Context) -> some MarkdownView {
        var content = ""
        if let url = Bundle.main.url(forResource: filename, withExtension: "md"),
           let data = try? Data(contentsOf: url),
           let str = String(data: data, encoding: .utf8) {
            content = str
        }
        
        imageParser.forEach{ paser in
            let imageurl  = Bundle.main.url(forResource: paser.imageName, withExtension: paser.extName)!
            let urlString = imageurl.absoluteString.deletingPrefix("file://")
            content = content.replacingOccurrences(of: paser.tmpName, with: urlString)
        }
        
        let bounds = CGRect(x: proxy.frame(in: .global).minX, y: proxy.frame(in: .global).minY, width: proxy.size.width, height: proxy.size.height)
        let mdView = MarkdownView(bounds: bounds)
        mdView.isScrollEnabled = isScrollEnable
        mdView.load(markdown: content, enableImage: enableImage)
        
        // called when user touch link
        mdView.onTouchLink = {  request in
          guard let url = request.url else { return false }
          UIApplication.shared.open(url)
          return false
        }
        return mdView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct MarkDownImageParser{
    let tmpName:String //md文件中的临时名称   tmpDemo
    let imageName:String //bundle中的图片文件名 demo
    let extName:String //图片的尾缀  png
    
    // ![image1](tmpDemo)   将被替换成  ![image](/var/dasggsad/demo.png)
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

//Sample
struct AboutView: View {
    let parsers:[MarkDownImageParser] = [MarkDownImageParser(tmpName: "demo.png", imageName: "demo", extName: "png")]
    var body: some View {
        GeometryReader{ proxy in
        MarkDownView(filename: "test", isScrollEnable: true, enableImage: true, imageParser: parsers,proxy: proxy)
            .edgesIgnoringSafeArea(.all)
        }
    }
