# Quick Start Guide - النشر السريع

## للمبتدئين - خطوة بخطوة

### 💻 على جهازك المحلي

**1. Clone المستودع:**
```bash
git clone https://github.com/abdulrahmanroston/tender-admin-app.git
cd tender-admin-app
```

**2. قم بالتعديلات التي تريدها**

**3. ارفع التعديلات:**
```bash
git add .
git commit -m "وصف التعديل"
git push
```

### 🌐 على السيرفر

**الإعداد الأولي (مرة واحدة فقط):**

```bash
# 1. اتصل بالسيرفر
ssh user@yourserver.com

# 2. انتقل لمجلد الموقع
cd /var/www/html

# 3. احذف المجلد القديم إن وُجد
rm -rf tender-admin-app

# 4. Clone من GitHub
git clone https://github.com/abdulrahmanroston/tender-admin-app.git

# 5. ادخل للمجلد
cd tender-admin-app

# 6. شغّل سكريبت الإعداد
chmod +x setup.sh
./setup.sh
```

**7. إعداد Webhook في GitHub:**

- افتح: https://github.com/abdulrahmanroston/tender-admin-app/settings/hooks
- اضغط "Add webhook"
- املأ البيانات:
  ```
  Payload URL: http://your-domain.com/tender-admin-app/deploy.php
  Content type: application/json
  Secret: اتركه فارغًا
  Events: Just the push event ✓
  ```
- اضغط "Add webhook"

### ✅ اختبار النظام

**على جهازك:**
```bash
echo "# Test" >> README.md
git add README.md
git commit -m "Test auto-deployment"
git push
```

**على السيرفر:**
```bash
tail -f deploy.log
```

يجب أن ترى رسائل النشر التلقائي!

---

## الأوامر المفيدة

### على السيرفر:

```bash
# عرض حالة النظام
./check-status.sh

# نشر يدوي
./deploy-manual.sh

# مشاهدة السجل مباشرة
tail -f deploy.log

# عرض آخر 50 سطر من السجل
tail -50 deploy.log

# البحث عن الأخطاء
grep ERROR deploy.log

# عرض النسخ الاحتياطية
ls -lh .deploy_backups/

# استعادة من نسخة احتياطية
tar -xzf .deploy_backups/backup_YYYYMMDD_HHMMSS.tar.gz
```

### على GitHub:

```bash
# التحقق من حالة Webhook
Settings → Webhooks → [اسم webhook] → Recent Deliveries
```

---

## استكشاف الأخطاء

### المشكلة: الملفات لا تتحدث

```bash
# على السيرفر
cd /var/www/html/tender-admin-app

# تحقق من حالة git
git status
git log -1

# تحقق من السجل
tail -20 deploy.log

# نشر يدوي
./deploy-manual.sh
```

### المشكلة: Permission denied

```bash
# إصلاح الصلاحيات
sudo chown -R www-data:www-data /var/www/html/tender-admin-app
chmod +x deploy.sh
chmod +x setup.sh
chmod +x deploy-manual.sh
chmod +x check-status.sh
chmod 666 deploy.log
chmod 777 .deploy_backups
```

### المشكلة: Webhook لا يعمل

1. تحقق من Recent Deliveries في GitHub
2. تأكد من أن URL صحيح
3. اختبر يدويًا:
```bash
curl -X POST http://your-domain.com/tender-admin-app/deploy.php \
  -H "Content-Type: application/json" \
  -d '{"ref":"refs/heads/main"}'
```

---

## النشر على عدة سيرفرات

كرر خطوات "على السيرفر" لكل سيرفر، ثم أضف webhook منفصل لكل سيرفر في GitHub.

---

## الدعم السريع

| المشكلة | الحل السريع |
|---------|------------|
| الملفات لا تتحدث | `./deploy-manual.sh` |
| Permission denied | `sudo chown -R www-data:www-data .` |
| Webhook failed | تحقق من Recent Deliveries |
| Git pull error | `git reset --hard origin/main` |
| Log file too large | `> deploy.log` (تفريغ) |

---

**للدليل الكامل:** [DEPLOYMENT.md](DEPLOYMENT.md)
