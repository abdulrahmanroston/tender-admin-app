# Tender Admin App

تطبيق إدارة المناقصات - نظام ويب كامل لإدارة المناقصات والمخازن والحسابات.

## 🚀 النشر التلقائي

هذا المستودع مجهز بنظام نشر تلقائي كامل. أي تحديث يتم رفعه إلى GitHub سيتم نشره تلقائيًا على السيرفر.

### الإعداد السريع (3 خطوات)

**1. على السيرفر:**
```bash
cd /var/www/html
git clone https://github.com/abdulrahmanroston/tender-admin-app.git
cd tender-admin-app
chmod +x deploy.sh
chmod 666 deploy.log
chmod 777 .deploy_backups
```

**2. في GitHub:**
- اذهب إلى [Settings → Webhooks](https://github.com/abdulrahmanroston/tender-admin-app/settings/hooks)
- أضف webhook جديد:
  - Payload URL: `https://your-domain.com/tender-admin-app/deploy.php`
  - Content type: `application/json`
  - Secret: اتركه فارغًا
  - Events: Just the push event

**3. اختبار:**
```bash
echo "test" >> test.txt
git add test.txt
git commit -m "Test deployment"
git push
```

### للمزيد من التفاصيل

اقرأ [دليل النشر الكامل](DEPLOYMENT.md)

## 📋 الملفات

- `index.html` - الصفحة الرئيسية
- `pos.html` - نقاط البيع
- `warehouses.html` - إدارة المخازن
- `acc.html` - الحسابات
- `navigation.js` - نظام التنقل
- `navigation.css` - تنسيق التنقل
- `manifest.json` - Progressive Web App config
- `sww.js` - Service Worker
- `icons/` - أيقونات التطبيق

## 🔒 ملفات النشر التلقائي

- `deploy.php` - معالج Webhook من GitHub
- `deploy.sh` - سكريبت النشر التلقائي
- `deploy.log` - سجل عمليات النشر
- `.deploy_backups/` - النسخ الاحتياطية التلقائية

## ✨ المميزات

- ✅ نشر تلقائي عند كل push
- ✅ نسخ احتياطية تلقائية
- ✅ سجلات كاملة
- ✅ استعادة تلقائية عند الفشل
- ✅ لا يحتاج إعدادات معقدة

## 📞 الدعم

في حالة وجود مشاكل:
1. تحقق من `deploy.log`
2. راجع webhook deliveries في GitHub
3. تأكد من صلاحيات الملفات

---

**المستودع**: https://github.com/abdulrahmanroston/tender-admin-app
