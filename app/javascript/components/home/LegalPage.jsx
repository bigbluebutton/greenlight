import React from 'react';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';

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
      title: 'Kullanim Kosullari',
      intro: 'Bu kosullar Akademio Live kullanimini duzenler. Platforma erisen veya platformu kullanan kurumlar ve kullanicilar bu kosullari kabul etmis sayilir.',
      lastUpdatedLabel: 'Son guncelleme',
      lastUpdatedValue: '27 Mart 2026',
      sections: [
        {
          title: 'Platform Kullanimi',
          paragraphs: [
            'Akademio Live, yasal egitim ve kurumsal egitim operasyonlari icin sunulur. Hizmeti sistem butunlugunu ve diger kullanicilari koruyacak sekilde kullanmalisiniz.',
          ],
          bullets: [
            'Yalnizca yetkili hesaplar kullanilmalidir.',
            'Yetkisiz erisim, tarama veya kesinti girisimleri yasaktir.',
            'Kurum ici ve mevzuat uyumluluk kurallarina uyulmalidir.',
          ],
        },
        {
          title: 'Hesaplar ve Erisim',
          paragraphs: [
            'Hesap sahipleri, kimlik bilgileri, rol atamalari ve hesap uzerinden yapilan islemlerden sorumludur.',
          ],
          bullets: [
            'Kimlik dogrulama bilgilerini guvenli tutun.',
            'En az yetki prensibi ile rol atayin.',
            'Supheli hesap ihlallerini hemen bildirin.',
          ],
        },
        {
          title: 'Veri, Kanit ve Saklama',
          paragraphs: [
            'Katilim kanitlari, oturum metaverisi ve ilgili kayitlar kurulum ayarlariniza ve kurum politikaniza gore yonetilir.',
          ],
          bullets: [
            'Saklama sureleri ortaminizda sizin tarafinizdan belirlenir.',
            'Disa aktarma, inceleme ve arsiv sureclerinden siz sorumlusunuz.',
            'Kurumsal verinizin sahipligi size aittir.',
          ],
        },
        {
          title: 'Hizmet Surekliligi ve Degisiklikler',
          paragraphs: [
            'Guvenlik, performans ve kararliligi artirmak icin platform yetenekleri guncellenebilir. Planli bakimlar gecici erisim etkisi yaratabilir.',
          ],
        },
        {
          title: 'Iletisim',
          paragraphs: [
            'Yasal veya uyumluluk sorulari icin platform yoneticinize veya destek kanalina basvurun.',
          ],
        },
      ],
    },
    privacy: {
      badge: 'Yasal',
      title: 'Gizlilik Politikasi',
      intro: 'Bu politika, Akademio Live tarafindan hangi verilerin islendigi ve bu verilerin guvenli sanal sinif hizmetleri icin nasil kullanildigini aciklar.',
      lastUpdatedLabel: 'Son guncelleme',
      lastUpdatedValue: '27 Mart 2026',
      sections: [
        {
          title: 'Islenen Veriler',
          paragraphs: [
            'Platform; sinif operasyonlari, katilim dogrulamasi ve raporlama icin gerekli hesap ve toplanti verilerini isler.',
          ],
          bullets: [
            'Hesap profili ve rol bilgileri.',
            'Toplanti katilim olaylari ve zaman damgalari.',
            'Yoklama yanitlari ve ilgili kanit kayitlari.',
            'Guvenlik ve tani icin gereken operasyon loglari.',
          ],
        },
        {
          title: 'Verilerin Kullanim Amaci',
          paragraphs: [
            'Veriler; platform isletimi, katilim guvencesi, guvenlik kontrolleri, analitik ve uyumluluk raporlamasi amaciyla kullanilir.',
          ],
          bullets: [
            'Toplanti hizmetini sunmak ve guvenligini saglamak.',
            'Katilim ve yonetisim raporlari olusturmak.',
            'Olay inceleme ve destek sureclerini yurutmek.',
          ],
        },
        {
          title: 'Veri Paylasimi',
          paragraphs: [
            'Akademio Live self-hosted mimari icin tasarlanmistir. Veri paylasimi kurumunuzun politikasi ve altyapi ayarlari tarafindan belirlenir.',
          ],
        },
        {
          title: 'Guvenlik ve Saklama',
          paragraphs: [
            'Saklama ve erisim politikalarini kurumunuz belirler. Yoneticiler rol izinlerini ve saklama surelerini kurum politikasina gore ayarlamalidir.',
          ],
        },
        {
          title: 'Haklariniz',
          paragraphs: [
            'Veri sahibi haklari, uygulanabilir hukuka uygun sekilde kurumunuz tarafindan yonetilir.',
          ],
        },
      ],
    },
  },
};

export default function LegalPage({ page = 'terms' }) {
  const { i18n } = useTranslation();
  const language = (i18n.resolvedLanguage || i18n.language || 'en')
    .toLowerCase()
    .startsWith('tr') ? 'tr' : 'en';
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
