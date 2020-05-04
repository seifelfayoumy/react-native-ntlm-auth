## How to install

`$ npm install react-native-ntlm-auth --save`


### React Native >= 0.60


### iOS
#### In your project's root:
```cd /ios``` <br>
`pod install`

### Android
Make sure you use jetifier and run it with npx after npm install
The package should be available automatically.

### React Native < 0.60

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-ntlm` and add `RNNtlm.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNNtlm.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNNtlmPackage;` to the imports at the top of the file
  - Add `new RNNtlmPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-ntlm'
  	project(':react-native-ntlm').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-ntlm/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-ntlm')
  	```

## How to use
```javascript

NativeModules.NTLMAuthentication.login(serverURL, username, password, headers)
    .then((response) => {

    })
    .catch((error) => {
        if (error.message === 'NO_INTERNET_CONNECTION_ERROR_MESSAGE') {
            // show your alert
        }
        else if (error.message === 'INVALID_USERNAME_OR_PASSWORD_ERROR_MESSAGE') {
            // show your alert
        }
        else { // show whatever message comes from the native module
            // show your alert
        }
    })
  ```

## Acknowledgments
    
  Many thanks to:
    Andrei Dobrescu and Arnaud Guyon (https://github.com/smart-fun)
   
