# شروط إغلاق الصفقات في مستشار التداول SADDAM Zone EA

يحتوي مستشار التداول الآلي [SADDAM Zone EA V1.10.2.mq4](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4) على عدة آليات وشروط لإغلاق صفقات السوق المفتوحة أو مسح الأوامر المعلقة. فيما يلي تفصيل هذه الشروط حسب مراحل عمل المستشار:

---

## 1. الإغلاق في الوضع العادي (Normal Grid Mode)

أثناء العمل الطبيعي لشبكة الصفقات، يتم فحص شروط الإغلاق التالية داخل دالة [OnTick](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L149):

* **تحقيق الهدف المالي الإجمالي للدورة (Target Profit):** 
  إذا تم تحديد هدف مالي بالمتغير `TARGET` (قيمة أكبر من 0)، وتجاوز مجموع الأرباح المحققة للصفقات المغلقة في الدورة الحالية بالإضافة للربح العائم الحالي قيمة الهدف:
  $$\text{TotalGainedProfit} + \text{TotalProfit} \ge \text{TARGET}$$
  يتم استدعاء الدالة [CloseAll](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L595) لإغلاق كل الصفقات المفتوحة وحذف المعلقة.

* **الوصول للحد الأقصى لعدد الصفقات (Max Trades):**
  إذا تم تفعيل خيار `CloseAtMaxTrades` وكان إجمالي الصفقات المفتوحة والمعلقة مساوياً أو أكبر من `MaxTrades` (بشرط أن لا تكون القيمة 0)، يقوم المستشار بإغلاق كل شيء فوراً عبر [CloseAll](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L595).

* **تحقيق الهدف بالدولار (Profit USD):**
  إذا تم تفعيل خيار `EnableProfitUSD` وتجاوز الربح العائم الحالي لجميع الصفقات المفتوحة (`TotalProfit`) القيمة المحددة في `TotalProfitUSD`، يتم استدعاء [CloseAll](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L595) فوراً.

* **جني الأرباح الموحد (Take Profit - TP):**
  تقوم دالة [ModifyAllOrdersTP](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L563) بتعديل مستمر لأخذ الربح لجميع صفقات الشراء أو صفقات البيع لتتحد عند متوسط سعر الدخول زائد أو ناقص قيمة الـ `TakeProfit` بالنقاط. عند وصول السعر إلى الهدف الموحد، تغلق الصفقات تلقائياً عبر خادم الميتاتريدر.

* **مسح الأوامر المعلقة عند خلو السوق (Zero Trades Cleanup):**
  إذا كان عدد صفقات السوق المفتوحة (شراء + بيع) يساوي 0، ولكن لا تزال هناك أوامر معلقة (Pending Orders) قائمة، يتم تصفيتها فوراً لمنع تفعلها بشكل منفصل.

* **خلل في توازن الشبكة (Grid Imbalance):**
  إذا فرغت جهة كاملة من الصفقات (مثال: لا يوجد أي صفقة بيع مفتوحة ولا أمر بيع معلق، أو العكس بالنسبة للشراء) وكان إجمالي عدد الصفقات المفتوحة أكبر من 1، فإن المستشار يقوم بإغلاق جميع الصفقات المتبقية كإجراء وقائي لمنع التعليق.

---

## 2. مرحلة التخفيف الجزئي ونقل الصفقات (Reduction & Transfer Logic)

عندما يتجاوز عدد الصفقات المفتوحة المتغير `MultiplierNumber` ويمر وقت قدره `WaitingMinutes` دقائق (أو يضغط المستخدم يدوياً على زر التخفيف "TransfairOrders"):

* **صفقات الشراء (BUY):**
  إذا تحرك السعر لصالح آخر صفقة شراء مفتوحة بمسافة تساوي أو تزيد عن `PipsToTransfair` نقاط:
  * إذا كان إجمالي صفقات الشراء رابحاً (`TotalProfit(OP_BUY) > 0`)، يتم إغلاق جميع صفقات الشراء [CloseAll(OP_BUY)](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L595).
  * إذا لم يكن الإجمالي رابحاً، يتم إغلاق آخر صفقة شراء مفتوحة فقط (بواسطة الـ Ticket).
  * يُستخدم الربح الناتج عن هذا الإغلاق لإغلاق جزء من الصفقات الخاسرة للبيع عبر دالة [ClosePercentOfLoss(OP_SELL, profit)](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L676) بناءً على النسبة المحددة في `PF_Percent`.
  * يتم مسح جميع أوامر البيع المعلقة `SELLSTOP`.

* **صفقات البيع (SELL):**
  إذا تحرك السعر لصالح آخر صفقة بيع مفتوحة بمسافة تساوي أو تزيد عن `PipsToTransfair` نقاط:
  * إذا كان إجمالي صفقات البيع رابحاً، يتم إغلاق جميع صفقات البيع [CloseAll(OP_SELL)](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L595).
  * إذا لم يكن الإجمالي رابحاً، يتم إغلاق آخر صفقة بيع مفتوحة فقط.
  * يُستخدم الربح الناتج لإغلاق جزء من صفقات الشراء الخاسرة عبر [ClosePercentOfLoss(OP_BUY, profit)](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L676).
  * يتم مسح جميع أوامر الشراء المعلقة `BUYSTOP`.

---

## 3. وضع التحوط لإدارة الأزمات (Hedging Mode)

يتم تفعيل هذا الوضع تلقائياً عندما يصل إجمالي عقود الشراء أو البيع المفتوحة إلى حجم `MaxLots`:

* **عند دخول وضع التحوط:**
  * يتم حذف كافة الأوامر المعلقة فوراً عبر دالة [DeleteAllPendingOrders()](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L828).
  * يتم إلغاء أخذ الربح (TP) لجميع الصفقات المفتوحة عبر دالة [DisableAllTakeProfits()](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L809) لضمان ثبات القفل (Lock) بنسبة 1:1 وعدم فكه جزئياً بطريقة غير محسوبة.

* **تقليص حجم التحوط (Hedge Reduction Cycle):**
  يعمل المستشار في هذه المرحلة على فترات زمنية محددة بـ `WaitingMinutes` (أو عند الضغط يدوياً على زر التخفيف):
  * عند تحرك السعر لصالح أي طرف (البيع أو الشراء) بـ `PipsToTransfair` نقاط، يتم إغلاق الطرف الرابح بالكامل (أو آخر صفقة منه) ويتم استخدام الأرباح الناتجة لتعويض وإغلاق جزء من خسارة الطرف الآخر عبر دالة [ClosePercentOfLoss](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L676).
  * بعد عملية التخفيف مباشرة، يتم حذف أوامر حماية التحوط (`Hedge Shield`) وإعادة قفل الحساب بنسبة 1:1 فوراً عبر `ExecuteLock()`.

* **الخروج النهائي من وضع التحوط:**
  عند تقليص حجم صفقات التحوط بنجاح ووصول إجمالي عقود الطرف الأكبر إلى حجم يساوي أو يقل عن `MinLots + 0.001` لوت:
  * يتم مسح أوامر حماية التحوط المعلقة عبر [DeleteAllPendingOrders()](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L828).
  * يتم إلغاء تفعيل وضع التحوط `IsHedgingMode = false` والعودة بسلاسة إلى تداول الشبكة العادي.

---

## 4. الإغلاق اليدوي من الشارت (Manual Controls)

* **زر "Close All" الرسومي:**
  عند قيام المستخدم بالنقر على زر "Close All" المتاح على واجهة الشارت، يتم استقبال الحدث عبر دالة [OnChartEvent](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L467) ويقوم الـ EA فوراً باستدعاء دالة [CloseAll()](file:///home/mohamed-yousry/work/trading/SADDAM%20Zone%20EA%20V1.10.2.mq4#L595) لتصفية كافة الصفقات المفتوحة وإلغاء جميع الأوامر المعلقة.
