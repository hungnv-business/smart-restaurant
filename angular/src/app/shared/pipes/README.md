# Shared Pipes

## VndCurrencyPipe

Custom pipe để format tiền tệ VND (Vietnamese Dong) cho toàn bộ hệ thống.

### Usage

```typescript
// Import trong component
import { VndCurrencyPipe } from '../../../../shared/pipes';

// Add vào imports array
@Component({
  // ...
  imports: [
    // other imports...
    VndCurrencyPipe,
  ],
})
```

```html
<!-- Basic usage - hiển thị với ký hiệu ₫ -->
{{ price | vndCurrency }}
<!-- Output: 1.000.000 ₫ -->

<!-- Không hiển thị ký hiệu -->
{{ price | vndCurrency:false }}
<!-- Output: 1.000.000 -->
```

### Features

- ✅ Automatic null/undefined handling: `null` → "Chưa có giá"
- ✅ Zero handling: `0` → "0 ₫"
- ✅ Vietnamese number formatting: `1000000` → "1.000.000 ₫"
- ✅ Optional symbol display
- ✅ Auto-rounding for decimal numbers
- ✅ Standalone pipe (Angular 17+)

### Examples

```typescript
VndCurrencyPipe.transform(null)          // "Chưa có giá"
VndCurrencyPipe.transform(undefined)     // "Chưa có giá"
VndCurrencyPipe.transform(0)             // "0 ₫"
VndCurrencyPipe.transform(1000)          // "1.000 ₫"
VndCurrencyPipe.transform(1000000)       // "1.000.000 ₫"
VndCurrencyPipe.transform(1000, false)   // "1.000"
```

### Use Cases

- Ingredient cost per unit
- Menu item prices
- Order totals
- Invoice amounts
- Financial reports
- Any VND currency display