//
//  TestRootView.swift
//  DesktopTestBed
//
//  Created by fincher on 4/14/21.
//

import SwiftUI

struct TestRootView: View {
    var body: some View {
        NavigationView {
            TestMasterView()
            TestDetailView()
        }
    }
}

struct TestRootView_Previews: PreviewProvider {
    static var previews: some View {
        TestRootView()
    }
}
