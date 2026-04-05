import 'package:flutter/material.dart';
import 'legal_texts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalTextPage(
      title: 'Gizlilik Politikası',
      paragraphs: [
        TextSpan(
          text:
              'Bu metin, KONUM platformunu demo / pilot aşamada değerlendiren kullanıcılar için hazırlanmıştır. '
              'Uygulama, kişisel verilerin korunmasına ilişkin yürürlükteki mevzuata saygı duyar ve verileri asgari düzeyde, '
              'belirli, açık ve meşru amaçlar için işler.\n\n',
        ),
        TextSpan(
          text: '1. İşlenen Kişisel Veriler\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Uygulama kapsamında ad-soyad, e-posta, telefon numarası, konum bilgisi, yolculuk geçmişi gibi bilgilerin işlenmesi mümkündür. '
              'Demo ortamında, bu veriler esas olarak ürünün işleyişini test etmek ve kullanıcı deneyimini iyileştirmek amacıyla kullanılmaktadır.\n\n',
        ),
        TextSpan(
          text: '2. İşleme Amaçları\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Kişisel verileriniz; sürücü ile yolcunun eşleştirilmesi, yolculuk özetlerinin oluşturulması, güvenlik ve suistimalin önlenmesi, '
              'hizmet kalitesinin ölçülmesi, istatistiksel analizler ve yasal yükümlülüklerin yerine getirilmesi amaçlarıyla işlenebilir.\n\n',
        ),
        TextSpan(
          text: '3. Veri Aktarımı\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Yasal yükümlülükler, yetkili makamların talebi veya açık rıza çerçevesinde; ilgili avukatlar, danışmanlar ve teknik hizmet sağlayıcılarla '
              'sınırlı olmak üzere veri aktarımı söz konusu olabilir.\n\n',
        ),
        TextSpan(
          text: '4. Saklama Süreleri\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Veriler, ilgili mevzuatta öngörülen süreler veya işleme amacının gerektirdiği süre boyunca saklanır; sonrasında silinir, yok edilir veya anonim hale getirilir.\n\n',
        ),
        TextSpan(
          text: '5. Haklarınız\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'KVKK kapsamında; verilerinize erişme, düzeltilmesini veya silinmesini talep etme, işlenmesini kısıtlama, itiraz etme gibi haklara sahipsiniz. '
              'Uygulama içindeki "Veri Silme Talebi" alanı üzerinden bu haklarınızı kullanabilirsiniz.\n\n',
        ),
        TextSpan(
          text: '6. Demo Uyarısı\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Bu metin, uygulamanın demo/pilot sürümü için hazırlanmış örnek bir gizlilik politikasıdır. '
              'Gerçek prod ortamında, bir hukuk uzmanı tarafından gözden geçirilmiş ve güncellenmiş halinin kullanılması önerilir.\n\n',
        ),
        TextSpan(
          text: LegalTexts.tbkGeneralReference,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

