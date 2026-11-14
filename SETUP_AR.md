# إعداد OMAR GAMING

## حالة المشروع
تم رفع كود واجهة الألعاب والبرامج ولوحة الإدارة وملف بناء APK. **لم يتم اختبار APK بعد**. شاشة البداية الحالية مؤقتة بنص OMAR GAMING، وليست فيديو الشعار؛ يجب إضافة فيديو الافتتاح الأصلي وتوصيله قبل الإصدار النهائي.

## بناء APK
افتح Actions > Build OMAR GAMING APK. سيعمل البناء تلقائياً عند تحديث main أو يمكن تشغيله يدوياً. بعد نجاحه حمّل artifact باسم OMAR-GAMING-APK.

## Firebase
1. أنشئ Firebase project وتطبيق Android بمعرّف com.omarayad.omar_gaming.
2. فعّل Authentication (Email/Password) وأنشئ حساب المالك، ثم انسخ UID.
3. فعّل Cloud Firestore و Storage.
4. في firestore.rules و storage.rules استبدل REPLACE_WITH_OWNER_UID بالـ UID ثم انشر القواعد في Firebase Console.
5. في GitHub > Settings > Secrets and variables > Actions أضف: FIREBASE_API_KEY و FIREBASE_APP_ID و FIREBASE_SENDER_ID و FIREBASE_PROJECT_ID و FIREBASE_STORAGE_BUCKET و OWNER_UID.
6. شغّل البناء مرة أخرى واختبر نشر لعبة أو برنامج من لوحة الإدارة.

## تنبيهات
- لا تنشر محتوى ليس لديك حق توزيعه.
- روابط منشورات القنوات الخاصة على Telegram قد لا تفتح إلا للأعضاء.
- الإصدار المبني افتراضياً مناسب للتجربة، وليس توزيعاً رسمياً موقّعاً بمفتاح إصدار دائم.
- تعديل المنشورات في النسخة الحالية يتم بنشر نسخة جديدة وحذف القديمة، ويحتاج تطويراً قبل الإصدار النهائي.
