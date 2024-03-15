import Flutter
import UIKit
import FincodeSDK

public class FlutterFincodePlugin: NSObject, FlutterPlugin, UIViewControllerTransitioningDelegate {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_fincode", binaryMessenger: registrar.messenger())
        let instance = FlutterFincodePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let errorInfo: [String : Any] = [
            "status": "failed",
            "message": "Parameter error.",
            "code": -1,
        ]
        switch call.method {
        case "cardInfoList":
            guard let args = call.arguments else {
                result(errorInfo)
                return
            }
            if let getArgs = args as? [String: Any] {
                cardInfoList(getArgs, result)
            }
        case "registerCard":
           guard let args = call.arguments else {
               result(errorInfo)
               return
           }
           if let getArgs = args as? [String: Any] {
               registerCard(getArgs, result)
           }
        case "showPaymentSheet":
            showPaymentSheet(result)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result("\(call.method) has not been implemented.")
        }
    }
    
    func cardInfoList(_ data: [String: Any], _ callback: @escaping FlutterResult) {
        let customerId = data["customerId"] as? String ?? ""
        FincodeCardOperateRepository.sharedInstance.cardInfoList(customerId, header: getHeader(data)) { result in
            let response: [String: Any?]
            switch result {
            case .success(let data):
                var cardList: Array = []
                data.cardInfoList.forEach { cardInfo in
                    cardList.append([
                        "id": cardInfo.id,
                        "customerId": cardInfo.customerId,
                        "cardNo": cardInfo.cardNo,
                        "brand": cardInfo.brand,
                        "holderName": cardInfo.holderName,
                        "expire": cardInfo.expire,
                    ])
                }
                response = [
                    "success": true,
                    "message": "successfully obtained.",
                    "data": cardList,
                ]
            case .failure(let error):
                response = [
                    "success": false,
                    "message": error.errorResponse.errors.first?.message ?? "",
                    "code": error.errorResponse.statusCode ?? 0,
                ]
            @unknown default:
                response = [
                    "success": false,
                    "message": "Unknown error.",
                    "code": -1,
                ]
                print("Unknown error.")
            }
           callback(response)
        }
    }
    
    func registerCard(_ data: [String: Any], _ callback: @escaping FlutterResult) {
        let params = data["params"] as? NSDictionary
        let request = FincodeCardRegisterRequest()
        let customerId = params?["customerId"] as? String ?? ""
        request.defaultFlag = params?["defaultFlag"] as? String ?? ""
        request.cardNo = params?["cardNo"] as? String ?? ""
        request.expire = params?["expire"] as? String ?? ""
        request.holderName = params?["holderName"] as? String ?? ""
        request.securityCode = params?["securityCode"] as? String ?? ""

        FincodeCardOperateRepository.sharedInstance.registerCard(customerId, request: request, header: getHeader(data)) { result in
            let response: [String: Any?]
            switch result {
            case .success(let data):
                response = [
                    "success": true,
                    "data": [
                        "id": data.id,
                        "customerId": data.customerId,
                        "cardNo": data.cardNo,
                        "expire": data.expire,
                        "holderName": data.holderName ?? "",
                        "brand": data.brand,
                    ],
                    "message": "Registered successfully.",
                ]
            case .failure(let error):
                response = [
                    "success": false,
                    "message": error.errorResponse.errors.first?.message ?? "",
                    "statusCode": error.errorResponse.statusCode ?? 0,
                ]
            @unknown default:
                response = [
                    "success": false,
                    "message": "Unknown error.",
                    "statusCode": -1,
                ]
            }
           callback(response)
        }
    }
    
    func showPaymentSheet(_ callback: @escaping FlutterResult) {
        let bundle = Bundle(for: PaymentViewController.self)
        let storyboard = UIStoryboard(name: "Payment", bundle: bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "sid_payment") as! PaymentViewController
        viewController.completionCallback = { result in
            callback(result)
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func getHeader(_ data: [String: Any]) -> [String : String] {
        let publishableKey = data["publishableKey"] ?? ""
        let tenantShopId = data["tenantShopId"] ?? ""
        return [
            "Content-Type": "application/json",
            "Authorization":"Bearer \(publishableKey)",
            "Tenant-Shop-Id": "\(tenantShopId)",
        ]
    }
}
