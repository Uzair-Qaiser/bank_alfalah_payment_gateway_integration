
# 🚀 Bank Alfalah Payment Gateway Integration  

This Flutter package allows seamless integration with **Bank Alfalah's Payment Gateway**.  
Ensure that your **merchant account is in production mode**, as sandbox credentials will not work.  

## 📦 Installation  

Add the package to your `pubspec.yaml`:  

```yaml
dependencies:
  bank_alfalah_payment_gateway_integration: latest_version
```

Run:

```sh
flutter pub get
```

## 🛠 Usage

Import the package:

```dart
import 'package:bank_alfalah_payment_gateway_integration/bank_alfalah_payment_gateway_integration.dart';
```

Use the `AlfalahPaymentIntegration` widget:

```dart
AlfalahPaymentIntegration(
  onSuccess: () {
    //Enter your logic here
    print("✅ Payment Successful!");
  },
  onFailure: () {
//Enter your logic here
    print("❌ Payment Failed!");
  },
  merchantDetails: MerchantDetails(
firstKey: 'Enter first key here', //You will get keys from bank alfalah
secondKey: 'Enter second key here',
merchantId: 'Enter your merchant id',
storeId: 'Enter your store id',
returnUrl: 'Enter your return url',
merchantHash: 'Enter your merchant hash',
merchantPass: 'Enter merchant pass here',
merchantUserName: 'Enter merchant username here'),
), // Provide your production merchant details
  transAmount: "Enter transaction amount here", // Transaction amount
);
```

### 📌 Parameters

| Parameter          | Type           | Description                                                                                         |
|--------------------|----------------|-----------------------------------------------------------------------------------------------------|
| `onSuccess`       | `VoidCallback` | Callback function triggered when payment is successful                                              |
| `onFailure`       | `VoidCallback` | Callback function triggered when payment fails                                                      |
| `merchantDetails` | `PaymentModel` | Merchant credentials (firstKey, secondKey, merchantId,storeId,returnUrl,merchantHash,merchantPass,merchantUserName) |
| `transAmount`     | `String`       | Transaction amount in PKR                                                                           |

## 🌟 Features

✔️ **Easy integration** with Bank Alfalah Payment Gateway  
✔️ **Handles success & failure callbacks**  
✔️ **Supports WebView-based payment flow**  
✔️ **Optimized for Flutter apps**

## 📜 Example

A complete example is available in the [`example/`](example/) directory.

## 📝 License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file for details.

---