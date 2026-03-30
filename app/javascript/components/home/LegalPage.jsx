import React from 'react';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import { getCurrentLanguage } from '../../helpers/LanguageHelper';

const LEGAL_COPY = {
  en: {
    terms: {
      badge: 'Legal',
      title: 'Terms of Service',
      intro: 'These terms govern your use of Akademio Live. By accessing or using the platform, your institution and users agree to these terms.',
      lastUpdatedLabel: 'Last updated',
      lastUpdatedValue: 'March 27, 2026',
      sections: [
        {
          title: 'Use of the Platform',
          paragraphs: [
            'Akademio Live is provided for lawful educational and training operations. You agree to use the service in a way that protects system integrity and other users.',
          ],
          bullets: [
            'Use authorized accounts only.',
            'Do not attempt unauthorized access, scanning, or disruption.',
            'Follow your institutional and regulatory compliance requirements.',
          ],
        },
        {
          title: 'Accounts and Access',
          paragraphs: [
            'Account owners are responsible for account credentials, role assignments, and actions performed through their accounts.',
          ],
          bullets: [
            'Keep authentication credentials secure.',
            'Use least-privilege role assignments.',
            'Report suspected account compromise immediately.',
          ],
        },
        {
          title: 'Data, Evidence, and Retention',
          paragraphs: [
            'Attendance evidence, session metadata, and related records are managed according to your deployment configuration and institutional policy.',
          ],
          bullets: [
            'You control retention windows in your environment.',
            'You are responsible for export, review, and archival workflows.',
            'Akademio Live does not transfer ownership of your institutional data.',
          ],
        },
        {
          title: 'Service Availability and Changes',
          paragraphs: [
            'We may update platform capabilities to improve security, performance, and reliability. Planned maintenance windows may affect availability.',
          ],
        },
        {
          title: 'Contact',
          paragraphs: [
            'For legal or compliance questions, contact your platform administrator or support channel.',
          ],
        },
      ],
    },
    privacy: {
      badge: 'Legal',
      title: 'Privacy Policy',
      intro: 'This policy explains what data Akademio Live processes and how that data is used to operate secure virtual classroom services.',
      lastUpdatedLabel: 'Last updated',
      lastUpdatedValue: 'March 27, 2026',
      sections: [
        {
          title: 'Data We Process',
          paragraphs: [
            'The platform processes account and meeting data needed to provide classroom operations, attendance verification, and reporting.',
          ],
          bullets: [
            'Account profile and role information.',
            'Meeting participation events and timestamps.',
            'Attendance check responses and related evidence records.',
            'Operational logs required for system security and diagnostics.',
          ],
        },
        {
          title: 'How Data Is Used',
          paragraphs: [
            'Data is used only for platform operation, attendance assurance, security controls, analytics, and compliance reporting.',
          ],
          bullets: [
            'Deliver and secure meeting services.',
            'Generate attendance and governance reports.',
            'Investigate incidents and support requests.',
          ],
        },
        {
          title: 'Data Sharing',
          paragraphs: [
            'Akademio Live is designed for self-hosted deployments. Data sharing is controlled by your institution and infrastructure configuration.',
          ],
        },
        {
          title: 'Security and Retention',
          paragraphs: [
            'Retention and access policies are controlled by your organization. Administrators should configure role permissions and retention windows according to policy.',
          ],
        },
        {
          title: 'Your Rights',
          paragraphs: [
            'Data subject rights, including access and correction, are handled through your institution according to applicable law.',
          ],
        },
      ],
    },
  },
  tr: {
    terms: {
      badge: 'Yasal',
      title: 'Kullanım Koşulları',
      intro: 'Bu koşullar Akademio Live kullanımını düzenler. Platforma erişen veya platformu kullanan kurumlar ve kullanıcılar bu koşulları kabul etmiş sayılır.',
      lastUpdatedLabel: 'Son güncelleme',
      lastUpdatedValue: '27 Mart 2026',
      sections: [
        {
          title: 'Platform Kullanımı',
          paragraphs: [
            'Akademio Live, yasal eğitim ve kurumsal eğitim operasyonları için sunulur. Hizmeti sistem bütünlüğünü ve diğer kullanıcıları koruyacak şekilde kullanmalısınız.',
          ],
          bullets: [
            'Yalnızca yetkili hesaplar kullanılmalıdır.',
            'Yetkisiz erişim, tarama veya kesinti girişimleri yasaktır.',
            'Kurum içi ve mevzuat uyumluluk kurallarına uyulmalıdır.',
          ],
        },
        {
          title: 'Hesaplar ve Erişim',
          paragraphs: [
            'Hesap sahipleri, kimlik bilgileri, rol atamaları ve hesap üzerinden yapılan işlemlerden sorumludur.',
          ],
          bullets: [
            'Kimlik doğrulama bilgilerini güvenli tutun.',
            'En az yetki prensibi ile rol atayın.',
            'Şüpheli hesap ihlallerini hemen bildirin.',
          ],
        },
        {
          title: 'Veri, Kanıt ve Saklama',
          paragraphs: [
            'Katılım kanıtları, oturum metaverisi ve ilgili kayıtlar kurulum ayarlarınıza ve kurum politikanıza göre yönetilir.',
          ],
          bullets: [
            'Saklama süreleri ortamınızda sizin tarafınızdan belirlenir.',
            'Dışa aktarma, inceleme ve arşiv süreçlerinden siz sorumlusunuz.',
            'Kurumsal verinizin sahipliği size aittir.',
          ],
        },
        {
          title: 'Hizmet Sürekliliği ve Değişiklikler',
          paragraphs: [
            'Güvenlik, performans ve kararlılığı artırmak için platform yetenekleri güncellenebilir. Planlı bakımlar geçici erişim etkisi yaratabilir.',
          ],
        },
        {
          title: 'İletişim',
          paragraphs: [
            'Yasal veya uyumluluk soruları için platform yöneticinize veya destek kanalına başvurun.',
          ],
        },
      ],
    },
    privacy: {
      badge: 'Yasal',
      title: 'Gizlilik Politikası',
      intro: 'Bu politika, Akademio Live tarafından hangi verilerin işlendiği ve bu verilerin güvenli sanal sınıf hizmetleri için nasıl kullanıldığını açıklar.',
      lastUpdatedLabel: 'Son güncelleme',
      lastUpdatedValue: '27 Mart 2026',
      sections: [
        {
          title: 'İşlenen Veriler',
          paragraphs: [
            'Platform; sınıf operasyonları, katılım doğrulaması ve raporlama için gerekli hesap ve toplantı verilerini işler.',
          ],
          bullets: [
            'Hesap profili ve rol bilgileri.',
            'Toplantı katılım olayları ve zaman damgaları.',
            'Yoklama yanıtları ve ilgili kanıt kayıtları.',
            'Güvenlik ve tanı için gereken operasyon logları.',
          ],
        },
        {
          title: 'Verilerin Kullanım Amacı',
          paragraphs: [
            'Veriler; platform işletimi, katılım güvencesi, güvenlik kontrolleri, analitik ve uyumluluk raporlaması amacıyla kullanılır.',
          ],
          bullets: [
            'Toplantı hizmetini sunmak ve güvenliğini sağlamak.',
            'Katılım ve yönetişim raporları oluşturmak.',
            'Olay inceleme ve destek süreçlerini yürütmek.',
          ],
        },
        {
          title: 'Veri Paylaşımı',
          paragraphs: [
            'Akademio Live self-hosted mimari için tasarlanmıştır. Veri paylaşımı kurumunuzun politikası ve altyapı ayarları tarafından belirlenir.',
          ],
        },
        {
          title: 'Güvenlik ve Saklama',
          paragraphs: [
            'Saklama ve erişim politikalarını kurumunuz belirler. Yöneticiler rol izinlerini ve saklama sürelerini kurum politikasına göre ayarlamalıdır.',
          ],
        },
        {
          title: 'Haklarınız',
          paragraphs: [
            'Veri sahibi hakları, uygulanabilir hukuka uygun şekilde kurumunuz tarafından yönetilir.',
          ],
        },
      ],
    },
  },
};

export default function LegalPage({ page = 'terms' }) {
  const { i18n } = useTranslation();
  const language = getCurrentLanguage(i18n, 'en');
  const content = LEGAL_COPY[language][page] || LEGAL_COPY.en.terms;

  return (
    <article className="ak-legal-page">
      <header className="ak-legal-hero">
        <span className="ak-legal-badge">{content.badge}</span>
        <h1>{content.title}</h1>
        <p>{content.intro}</p>
        <span className="ak-legal-updated">
          {content.lastUpdatedLabel}: {content.lastUpdatedValue}
        </span>
      </header>

      <div className="ak-legal-card">
        {content.sections.map((section) => (
          <section className="ak-legal-section" key={section.title}>
            <h2>{section.title}</h2>
            {section.paragraphs?.map((paragraph) => (
              <p key={`${section.title}-${paragraph}`}>{paragraph}</p>
            ))}
            {section.bullets?.length > 0 && (
              <ul>
                {section.bullets.map((bullet) => (
                  <li key={`${section.title}-${bullet}`}>{bullet}</li>
                ))}
              </ul>
            )}
          </section>
        ))}
      </div>
    </article>
  );
}

LegalPage.propTypes = {
  page: PropTypes.oneOf(['terms', 'privacy']),
};
