package co.airhost.flutter_fincode

import android.content.Context
import androidx.annotation.NonNull
import com.epsilon.fincode.fincodesdk.Repository.FincodeCardOperateRepository
import com.epsilon.fincode.fincodesdk.api.FincodeCallback
import com.epsilon.fincode.fincodesdk.entities.api.FincodeCardInfoListResponse
import com.epsilon.fincode.fincodesdk.entities.api.FincodeCardRegisterRequest
import com.epsilon.fincode.fincodesdk.entities.api.FincodeCardRegisterResponse
import com.epsilon.fincode.fincodesdk.entities.api.FincodeErrorResponse
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterFincodePlugin */
class FlutterFincodePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_fincode")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val errorInfo = mapOf(
            "status" to "failed",
            "message" to "Parameter error.",
            "code" to -1,
        )
        when (call.method) {
            "cardInfoList" -> {
                if (call.arguments !is Map<*, *>) {
                    result.success(errorInfo)
                    return
                }
                cardInfoList(call.arguments as Map<*, *>, result)
            }
            "registerCard" -> {
                if (call.arguments !is Map<*, *> || (call.arguments as Map<*, *>)["params"] !is Map<*, *>?) {
                    result.success(errorInfo)
                    return
                }
                registerCard(call.arguments as Map<*, *>, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun cardInfoList(data: Map<*, *>, @NonNull result: Result) {
        val customerId: String = data["customerId"]?.toString() ?: ""
        FincodeCardOperateRepository.getInstance()?.getCardInfoList(
            getHeader(data), customerId,
            object : FincodeCallback<FincodeCardInfoListResponse> {
                override fun onResponse(response: FincodeCardInfoListResponse) {
                    val cardList = response.cardInfoList.map { cardInfo ->
                        mapOf(
                            "id" to cardInfo.cardId,
                            "customerId" to cardInfo.customerId,
                            "cardNo" to cardInfo.cardNo,
                            "brand" to cardInfo.cardBrand,
                            "holderName" to cardInfo.holderName,
                            "expire" to cardInfo.expire
                        )
                    }
                    result.success(mapOf(
                        "success" to true,
                        "message" to "successfully obtained.",
                        "data" to cardList
                    ))
                }

                override fun onFailure(error: FincodeErrorResponse) {
                    result.success(getFailureResult(error))
                }
            },
        )
    }

    private fun registerCard(data: Map<*, *>, @NonNull result: Result) {
        val params = data["params"] as Map<*, *>?
        val customerId = params?.get("customerId")?.toString() ?: ""
        val request = FincodeCardRegisterRequest().apply {
            defaltFlag = params?.get("defaultFlag")?.toString() ?: ""
            cardNo = params?.get("cardNo")?.toString() ?: ""
            expire = params?.get("expire")?.toString() ?: ""
            holderName = params?.get("holderName")?.toString() ?: ""
            securityCode = params?.get("securityCode")?.toString() ?: ""
        }

        FincodeCardOperateRepository.getInstance()?.cardRegister(
            getHeader(data), customerId, request,
            object : FincodeCallback<FincodeCardRegisterResponse> {
                override fun onResponse(response: FincodeCardRegisterResponse) {
                    result.success(mapOf(
                        "success" to true,
                        "message" to "Registered successfully.",
                        "data" to mapOf(
                            "id" to response.cardId,
                            "customerId" to response.customerId,
                            "cardNo" to response.cardNo,
                            "expire" to response.expire,
                            "holderName" to response.holderName,
                            "brand" to response.cardBrand,
                        ),
                    ))
                }

                override fun onFailure(error: FincodeErrorResponse) {
                    result.success(getFailureResult(error))
                }
            },
        )
    }

    private fun getHeader(data: Map<*, *>): HashMap<String, String> {
        val publicKey: String = data["publicKey"]?.toString() ?: ""
        val tenantShopId: String = data["tenantShopId"]?.toString() ?: ""
        return hashMapOf(
            "Content-Type" to "application/json",
            "Authorization" to "Bearer $publicKey",
            "Tenant-Shop-Id" to tenantShopId,
        )
    }

    private fun getFailureResult(error: FincodeErrorResponse): Map<String, *> {
        return mapOf(
            "success" to false,
            "message" to (error.errorInfo.list.firstOrNull()?.message ?: ""),
            "code" to error.statusCode
        )
    }
}
