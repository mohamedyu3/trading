# تعديلات منطق التعافي (Recovery Logic) - SADDAM Zone EA V1.4

تم تعديل منطق الإكسبيرت في قسم "نقل الصفقات" (Transfer/Transfair) لزيادة المهاجمة عند محاولة الخروج من الصفقات الخاسرة المتبقية.

## التغييرات الرئيسية:

### 1. في حالة إغلاق صفقات الشراء المربحة:
*   **سابقاً:** كان يتم فتح صفقة شراء جديدة بحجم `TotalLots(OP_SELL) + F_Lots`.
*   **حالياً:** يتم حساب العقود المتبقية للبيع، ثم فتح صفقة شراء سوقية بحجم:
    `العقود المتبقية للبيع * Multiplier`.
*   **الأمر المعلق:** يتم وضع أمر بيع معلق (SELL STOP) بحجم:
    `حجم صفقة الشراء المفتوحة مؤخراً * Multiplier`.

### 2. في حالة إغلاق صفقات البيع المربحة:
*   **سابقاً:** كان يتم فتح صفقة بيع جديدة بحجم `TotalLots(OP_BUY) + F_Lots`.
*   **حالياً:** يتم حساب العقود المتبقية للشراء، ثم فتح صفقة بيع سوقية بحجم:
    `العقود المتبقية للشراء * Multiplier`.
*   **الأمر المعلق:** يتم وضع أمر شراء معلق (BUY STOP) بحجم:
    `حجم صفقة البيع المفتوحة مؤخراً * Multiplier`.

---

## الكود المعدل (مثال صفقات الشراء):

```mq4
// حساب العقود المتبقية للبيع
double remainingSellLots = TotalLots(OP_SELL);
// حساب حجم عقد الشراء الجديد بالمضاعفة
newLot = NormalizeDouble(remainingSellLots * Multiplier, lot_digits);
ticket = OrderSend(Symbol(), OP_BUY, newLot, NormalizeDouble(Ask, Digits), 3 * P, SL, TP, "EA", MagicNumber, 0, Blue);

// حساب حجم العقد المعلق (SELL STOP) بالمضاعفة أيضاً
double newLotPending = NormalizeDouble(newLot * Multiplier, lot_digits);
ticket = OrderSend(Symbol(), OP_SELLSTOP, newLotPending, NormalizeDouble(price, Digits), 3 * P, SL, TP, "EA", MagicNumber, 0, Red);
```

> [!IMPORTANT]
> **ملاحظة:** تم استخدام المتغير `Multiplier` كمعامل ضرب بدلاً من `MultiplierNumber` لضمان استقرار الحساب وتوافق النتائج مع إعداداتك.
