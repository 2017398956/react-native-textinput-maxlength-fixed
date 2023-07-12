# react-native-textinput-maxlength-fixed

fix TextInput's maxLength bug when  using a non-English input method.

引入后不需要 import ，如果不起作用，直接复制 RCTBaseTextInputView+Helper.h RCTBaseTextInputView+Helper.mm 到你的 iOS 项目即可。

## Installation

```sh
npm install react-native-textinput-maxlength-fixed
```

## Usage

```js
import { multiply } from 'react-native-textinput-maxlength-fixed';

// ...

const result = await multiply(3, 7);
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
