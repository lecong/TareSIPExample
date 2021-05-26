//
//  ViewController.swift
//  TareSIPExample
//
//  Created by Le Ngoc Cong on 26/05/2021.
//

import UIKit

enum SipError: Error {
    case libre
    case config
    case stack
    case modules
    case userAgent
    case call
}

final class SipClient {

    required init?(agent: inout OpaquePointer?) throws {
        guard libre_init() == 0 else { throw SipError.libre }

        // Initialize dynamic modules.
        mod_init()

        // Make configure file.
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            conf_path_set(path)
        }
        guard conf_configure() == 0 else { throw SipError.config }

        // Initialize the SIP stack.
        guard ua_init("SIP", 1, 1, 1, 0) == 0 else { throw SipError.stack }

        // Load modules.
        guard conf_modules() == 0 else { throw SipError.modules }
        
        let userId = "w_wsyhokxaojb3"
        let audioSessionNum = 1
        let userName = "LeCong"
        let addr = "sip:\(userId)_\(audioSessionNum)-bbbID-\(userName)@bbbtest.eastus.cloudapp.azure.com;transport=udp;answermode=auto"

        // Start user agent.
        guard ua_alloc(&agent, addr) == 0 else { throw SipError.userAgent }

        // Make an outgoing call.
//        guard ua_connect(agent, nil, nil, "sip:target@server.com:port", nil, VIDMODE_OFF) == 0 else { throw SipError.call }

        // Start the main loop.
        re_main(nil)
    }

    func close(agent: OpaquePointer) {
        mem_deref(UnsafeMutablePointer(agent))
        ua_close()
        mod_close()

        // Close and check for memory leaks.
        libre_close()
        tmr_debug()
        mem_debug()
    }

}

class ViewController: UIViewController {
    
    var agent: OpaquePointer? = nil
    var client: SipClient? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            client = try SipClient(agent: &agent)
        } catch {
            print("error: \(error)")
        }
    }
}

