// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  AdjustmentsHorizontalIcon,
  ArrowRightIcon,
  CalendarDaysIcon,
  ChartBarIcon,
  ClockIcon,
  DocumentArrowDownIcon,
  UserGroupIcon,
} from '@heroicons/react/24/outline';
import { toast } from 'react-toastify';
import { useAuth } from '../../contexts/auth/AuthProvider';
import useEnv from '../../hooks/queries/env/useEnv';

const HERO_BACKGROUND = '/images/hero-bg.png';
const ANALYTICS_IMAGE = 'https://storage.googleapis.com/dala-prod-public-storage/generated-images/c6a1b98a-9c93-482f-83af-adabd30c0a48/analytics-feature-graphic-1e115823-1772174458299.webp';
const SECURITY_IMAGE = 'https://storage.googleapis.com/dala-prod-public-storage/generated-images/c6a1b98a-9c93-482f-83af-adabd30c0a48/security-feature-graphic-4d428a1a-1772174458072.webp';

const MARKETING_COPY = {
  en: {
    hero: {
      badge: 'Attendance Assurance Platform',
      title: 'Secure, Self-Hosted Virtual Classroom Software',
      subtitle: 'Akademio Live helps institutions run secure virtual classrooms with verifiable attendance, real-time instructor controls, and audit-ready analytics for performance-critical training.',
      primaryCta: 'Book a Demo',
      secondaryCta: 'Sign In',
      metrics: [
        ['Attendance', 'Verified'],
        ['Exports', 'JSON / CSV'],
        ['Governance', 'Audit-Ready'],
      ],
      trust: ['Built on BigBlueButton', 'GDPR Ready', 'Self-Hosted'],
    },
    trustStrip: ['Ministry of Education', 'Procurement Governance', 'Law Academy', 'Institutional Training', 'Compliance Ops'],
    howItWorks: {
      badge: 'How It Works',
      title: 'Enterprise-grade virtual learning, simplified.',
      steps: [
        {
          index: '01',
          title: 'Self-Hosted Control',
          description: 'Deploy on your own infrastructure for complete data sovereignty, privacy control, and institutional ownership.',
        },
        {
          index: '02',
          title: 'Verify Attendance',
          description: 'Enforce participation integrity with timed attendance checks, quiz prompts, and moderator-issued controls.',
        },
        {
          index: '03',
          title: 'Generate Evidence',
          description: 'Export audit-ready reports and user-level evidence logs for review, governance, and stakeholder reporting.',
        },
      ],
    },
    analytics: {
      badge: 'Dual Analytics Experience',
      title: 'Learning analytics that drive governance.',
      body: 'Combine native BigBlueButton insights with Akademio operational dashboards to monitor participation integrity, compliance outcomes, and room-level controls from one interface.',
      points: [
        ['Meeting Summaries', 'Clear session-level compliance and attendance visibility.'],
        ['Exportable Reports', 'Instant CSV/JSON evidence packs for audit review.'],
      ],
    },
    features: {
      badge: 'Features',
      title: 'Virtual Classroom, Analytics and Attendance',
      subtitle: 'Standard webinar tools fail institutional audits. Akademio Live is built to provide trusted evidence.',
      items: [
        ['Timed Participation Checks', 'Trigger random attendance verification that learners must acknowledge to prove presence.'],
        ['Per-User Evidence Logs', 'Track entry, exit, response timing, outcomes, and interaction history per participant.'],
        ['Operational Dashboard', 'Go beyond basic metrics with Akademio analytics built for governance and room-level oversight.'],
        ['Calendar Integrations', 'Sync upcoming classroom sessions with Outlook, Google, and Apple calendars.'],
        ['Audit-Ready Exports', 'Download session summaries and evidence packages in CSV and JSON formats.'],
        ['Instructor Controls', 'Give moderators live tools for participation enforcement in high-stakes training sessions.'],
      ],
    },
    governance: {
      badge: 'Governance and Privacy',
      title: 'Total control over your data and infrastructure.',
      items: [
        ['On-Premise Deployment', 'Keep sensitive training data inside your own network and policy boundaries.'],
        ['Audit Integrity', 'Record critical actions with tamper-evident timestamps for complete accountability.'],
        ['Data Sovereignty', 'No third-party dependency for records ownership. Your institution keeps full control.'],
      ],
    },
    comparison: {
      badge: 'Comparison',
      title: 'Why Akademio Live?',
      subtitle: 'Standard tools versus an attendance assurance platform.',
      headers: ['Feature', 'Standard Tools', 'Akademio Live'],
      rows: [
        ['Attendance Proof', 'Passive connection logs', 'Active, timed verification'],
        ['Data Sovereignty', 'Public cloud defaults', 'Private cloud, self-hosted'],
        ['Audit Readiness', 'Basic statistics', 'Full forensic evidence packs'],
        ['Instructor Control', 'Limited focus tools', 'Real-time engagement enforcement'],
        ['Evidence Quality', 'Informal', 'Audit-ready for stakeholders'],
      ],
    },
    pricing: {
      badge: 'Pricing',
      title: 'Scale your institution',
      subtitle: 'Transparent models for professional education and governance.',
      featuredBadge: 'Most Popular',
      buttonDefault: 'Learn More',
      buttonFeatured: 'Contact Sales',
      plans: [
        {
          name: 'Pilot',
          price: 'Custom',
          description: 'Test attendance assurance workflows with guided implementation.',
          features: ['Up to 50 concurrent users', 'Standard analytics', 'Proof-of-concept setup'],
        },
        {
          name: 'Institutional',
          price: 'Contact Us',
          description: 'For training centers, public institutions, and governance-focused teams.',
          features: ['Unlimited sessions', 'Custom branding', 'ICS calendar feeds'],
          featured: true,
        },
        {
          name: 'Infrastructure',
          price: 'Inquire',
          description: 'Full-scale private cloud deployment with dedicated architecture.',
          features: ['Dedicated cluster', 'SLA guarantees', 'SSO and LDAP readiness'],
        },
      ],
    },
    faq: {
      badge: 'FAQ',
      title: 'Frequently Asked Questions',
      items: [
        ['What makes Akademio Live different from standard BigBlueButton?', 'It extends BigBlueButton with an attendance assurance layer: scheduled verification, advanced dashboards, and audit-ready reporting.'],
        ['How does attendance assurance work?', 'The platform issues timed attendance and quiz checks that participants must answer within a defined window.'],
        ['Is data stored on third-party servers?', 'No. Akademio Live is designed for self-hosting so your institution controls where all classroom data lives.'],
        ['Can we export reports for auditors and stakeholders?', 'Yes. Every session can generate structured evidence packs in CSV and JSON formats for review workflows.'],
      ],
    },
    cta: {
      badge: 'Request a Demo',
      title: 'Upgrade your virtual classroom operations.',
      body: 'Join institutions using Akademio Live to power secure, verifiable training and governance-ready learning operations.',
      points: [
        'Fast institutional setup on private infrastructure',
        'Governance-ready evidence exports for internal and external review',
        'Supports high-stakes education, compliance, and certification workflows',
      ],
      labels: {
        name: 'Full Name',
        org: 'Institution Name',
        email: 'Institutional Email',
        useCase: 'Training Use Case',
      },
      placeholders: {
        name: 'Jane Smith',
        org: 'National Academy',
        email: 'jane@institution.gov',
        useCase: 'Institutional Training',
      },
      button: 'Book My Demo',
      note: 'No credit card required • GDPR ready • Private deployment',
    },
  },
  tr: {
    hero: {
      badge: 'Katilim Guvencesi Platformu',
      title: 'Guvenli, Kendi Sunucunuzda Sanal Sinif Yazilimi',
      subtitle: 'Akademio Live; kurumlara dogrulanabilir katilim, gercek zamanli egitmen kontrolleri ve denetime hazir analizlerle guvenli sanal siniflar sunar.',
      primaryCta: 'Demo Talebi',
      secondaryCta: 'Giris Yap',
      metrics: [
        ['Katilim', 'Dogrulandi'],
        ['Cikti', 'JSON / CSV'],
        ['Yonetisim', 'Denetime Hazir'],
      ],
      trust: ['BigBlueButton Uzerinde', 'KVKK / GDPR Hazir', 'Self-Hosted'],
    },
    trustStrip: ['Milli Egitim', 'Tedarik Yonetisimi', 'Hukuk Akademisi', 'Kurumsal Egitim', 'Uyumluluk Operasyonlari'],
    howItWorks: {
      badge: 'Nasil Calisir',
      title: 'Kurumsal duzeyde sanal ogrenim, sade sekilde.',
      steps: [
        {
          index: '01',
          title: 'Self-Hosted Kontrol',
          description: 'Tam veri egemenligi, gizlilik kontrolu ve kurumsal sahiplik icin kendi altyapiniza kurun.',
        },
        {
          index: '02',
          title: 'Katilimi Dogrulayin',
          description: 'Sureli yoklama kontrolleri, quiz istemleri ve moderator kontrolleri ile katilim butunlugunu saglayin.',
        },
        {
          index: '03',
          title: 'Kanit Uretin',
          description: 'Inceleme, yonetisim ve paydas raporlamasi icin denetime hazir raporlari ve kullanici bazli kanitlari disa aktarın.',
        },
      ],
    },
    analytics: {
      badge: 'Cift Analitik Deneyimi',
      title: 'Yonetisimi guclendiren ogrenim analitigi.',
      body: 'Native BigBlueButton gorunurlerini Akademio operasyon panelleri ile birlestirin; katilim butunlugunu, uyumluluk ciktilarini ve oda kontrollerini tek arayuzden yonetin.',
      points: [
        ['Toplanti Ozetleri', 'Oturum bazli uyumluluk ve katilim gorunurlugu.'],
        ['Disa Aktarilabilir Raporlar', 'Denetim icin anlik CSV/JSON kanit paketleri.'],
      ],
    },
    features: {
      badge: 'Ozellikler',
      title: 'Sanal Sinif, Analitik ve Katilim',
      subtitle: 'Standart webinar araclari kurumsal denetimlerde yetersiz kalir. Akademio Live guvenilir kanit icin tasarlandi.',
      items: [
        ['Sureli Katilim Kontrolleri', 'Ogrencilerin varligini kanitlamasi icin onaylamasi gereken rastgele yoklama dogrulamalari.'],
        ['Kullanici Bazli Kanit Kayitlari', 'Her katilimcinin giris, cikis, yanit sureleri ve etkileşim gecmisi.'],
        ['Operasyon Paneli', 'Kurumsal yonetisim ve oda bazli denetim icin temel metriklerin otesine gecin.'],
        ['Takvim Entegrasyonlari', 'Gelecek siniflari Outlook, Google ve Apple takvimleriyle esitleyin.'],
        ['Denetime Hazir Ciktilar', 'Oturum ozetlerini ve kanit paketlerini CSV/JSON formatinda indirin.'],
        ['Egitmen Kontrolleri', 'Yuksek onemli egitimlerde katilimi zorlayan canli moderator araclari.'],
      ],
    },
    governance: {
      badge: 'Yonetisim ve Gizlilik',
      title: 'Veriniz ve altyapiniz uzerinde tam kontrol.',
      items: [
        ['Yerinde Kurulum', 'Hassas egitim verilerini kendi ag sinirlariniz icinde tutun.'],
        ['Denetim Butunlugu', 'Kritik islemleri degistirilemez zaman damgalari ile kaydedin.'],
        ['Veri Egemenligi', 'Kayit sahipligi icin ucuncu taraf bagimliligi yoktur. Tum kontrol sizde kalir.'],
      ],
    },
    comparison: {
      badge: 'Karsilastirma',
      title: 'Neden Akademio Live?',
      subtitle: 'Standart araclar ile katilim guvencesi platformu arasindaki fark.',
      headers: ['Ozellik', 'Standart Araclar', 'Akademio Live'],
      rows: [
        ['Katilim Kaniti', 'Pasif baglanti kayitlari', 'Aktif, sureli dogrulama'],
        ['Veri Egemenligi', 'Genel bulut varsayilanlari', 'Ozel bulut, self-hosted'],
        ['Denetime Hazirlik', 'Temel istatistikler', 'Tam adli kanit paketleri'],
        ['Egitmen Kontrolu', 'Sinirli odak araclari', 'Gercek zamanli katilim zorlama'],
        ['Kanit Kalitesi', 'Gayriresmi', 'Paydaslar icin denetime hazir'],
      ],
    },
    pricing: {
      badge: 'Fiyatlandirma',
      title: 'Kurumunuzu olceklendirin',
      subtitle: 'Profesyonel egitim ve yonetisim icin seffaf modeller.',
      featuredBadge: 'En Cok Tercih Edilen',
      buttonDefault: 'Detaylari Incele',
      buttonFeatured: 'Satis ile Gorusun',
      plans: [
        {
          name: 'Pilot',
          price: 'Ozel',
          description: 'Katilim guvencesi is akislarini yonlendirmeli sekilde test edin.',
          features: ['50 eszamanli kullaniciya kadar', 'Standart analitik', 'PoC kurulum'],
        },
        {
          name: 'Kurumsal',
          price: 'Iletisime Gecin',
          description: 'Egitim merkezleri, kamu kurumlari ve yonetisim odakli ekipler icin.',
          features: ['Sinirsiz oturum', 'Ozel markalama', 'ICS takvim akislari'],
          featured: true,
        },
        {
          name: 'Altyapi',
          price: 'Teklif Alin',
          description: 'Ozel mimari ile tam olcekli private cloud kurulumu.',
          features: ['Ozel kume', 'SLA garantileri', 'SSO ve LDAP hazirligi'],
        },
      ],
    },
    faq: {
      badge: 'SSS',
      title: 'Sikca Sorulan Sorular',
      items: [
        ['Akademio Live standart BigBlueButton\'dan nasil ayrilir?', 'BigBlueButton cekirdegini; planli dogrulama, gelismis paneller ve denetime hazir raporlama ile genisletir.'],
        ['Katilim guvencesi nasil calisir?', 'Platform, katilimcilarin belirli bir sure icinde yanitlamasi gereken sureli yoklama ve quiz kontrolleri gonderir.'],
        ['Veri ucuncu taraf sunucularda mi saklaniyor?', 'Hayir. Akademio Live self-hosted icin tasarlanmistir; tum verilerin nerede tutuldugu sizin kontrolunuzdedir.'],
        ['Denetciler ve paydaslar icin rapor disa aktarilabilir mi?', 'Evet. Her oturum, inceleme surecleri icin yapilandirilmis CSV ve JSON kanit paketleri uretebilir.'],
      ],
    },
    cta: {
      badge: 'Demo Talebi',
      title: 'Sanal sinif operasyonlarinizi gelistirin.',
      body: 'Akademio Live kullanan kurumlara katilin; guvenli, dogrulanabilir egitim ve yonetisim odakli ogrenim operasyonlari kurun.',
      points: [
        'Private altyapida hizli kurumsal kurulum',
        'Ic ve dis inceleme icin denetime hazir kanit ciktilari',
        'Yuksek onemli egitim, uyumluluk ve sertifikasyon sureclerine uygun',
      ],
      labels: {
        name: 'Ad Soyad',
        org: 'Kurum Adi',
        email: 'Kurumsal E-Posta',
        useCase: 'Egitim Kullanimi',
      },
      placeholders: {
        name: 'Ayse Yilmaz',
        org: 'Ulusal Akademi',
        email: 'ayse@kurum.gov.tr',
        useCase: 'Kurumsal Egitim',
      },
      button: 'Demomu Planla',
      note: 'Kredi karti gerekmez • GDPR hazir • Private deployment',
    },
  },
};

const FEATURE_ICONS = [
  ClockIcon,
  UserGroupIcon,
  ChartBarIcon,
  CalendarDaysIcon,
  DocumentArrowDownIcon,
  AdjustmentsHorizontalIcon,
];

export default function HomePage() {
  const { t, i18n } = useTranslation();
  const currentUser = useAuth();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const [openFaqIndex, setOpenFaqIndex] = useState(0);
  const error = searchParams.get('error');
  const success = searchParams.get('success');
  const { data: env } = useEnv();
  const language = (i18n.resolvedLanguage || i18n.language || currentUser?.language || 'en').toLowerCase().startsWith('tr') ? 'tr' : 'en';
  const copy = MARKETING_COPY[language];

  const featureCards = useMemo(
    () => copy.features.items.map(([title, description], index) => ({
      title,
      description,
      Icon: FEATURE_ICONS[index],
    })),
    [copy],
  );

  useEffect(
    () => {
      if (!currentUser.stateChanging && currentUser.signed_in && currentUser.permissions.CreateRoom === 'true') {
        navigate('/rooms');
      } else if (!currentUser.stateChanging && currentUser.signed_in && currentUser.permissions.CreateRoom === 'false') {
        navigate('/home');
      }
    },
    [currentUser.signed_in],
  );

  useEffect(() => {
    switch (success) {
      case 'LogoutSuccessful':
        toast.success(t('toast.success.session.signed_out'));
        break;
      default:
    }
    if (success) { setSearchParams(searchParams.delete('success')); }
  }, [success]);

  useEffect(() => {
    switch (error) {
      case 'InviteInvalid':
        toast.error(t('toast.error.users.invalid_invite'));
        break;
      case 'SignupError':
        toast.error(t('toast.error.users.signup_error'));
        break;
      case 'BannedUser':
        toast.error(t('toast.error.users.banned'));
        break;
      default:
    }
    if (error) { setSearchParams(searchParams.delete('error')); }
  }, [error]);

  useEffect(
    () => {
      const inviteToken = searchParams.get('inviteToken');

      if (!env || !inviteToken) {
        return;
      }

      const query = searchParams.toString();
      const target = env.EXTERNAL_AUTH ? '/signin' : '/signup';
      navigate(query ? `${target}?${query}` : target, { replace: true });
    },
    [searchParams, env],
  );

  return (
    <div className="ak-landing ak-landing-rich">
      <div className="ak-home-bg ak-home-bg-a" aria-hidden="true" />
      <div className="ak-home-bg ak-home-bg-b" aria-hidden="true" />
      <div className="ak-home-gridwash" aria-hidden="true" />

      <section className="ak-home-hero-shell" style={{ backgroundImage: `url(${HERO_BACKGROUND})` }}>
        <div className="ak-home-hero-stage">
          <div className="ak-home-hero-copy ak-home-hero-copy-overlay">
            <span className="ak-home-badge ak-home-badge-on-dark">{copy.hero.badge}</span>
            <h1>{copy.hero.title}</h1>
            <p className="ak-home-subheadline ak-home-subheadline-on-dark">{copy.hero.subtitle}</p>
            <div className="ak-home-hero-actions">
              <a href="/#demo-form" className="btn btn-brand ak-home-primary-btn">{copy.hero.primaryCta}</a>
              <a href="/signin" className="btn btn-brand-outline-color ak-home-secondary-btn">{copy.hero.secondaryCta}</a>
            </div>
            <div className="ak-home-hero-metrics">
              {copy.hero.metrics.map(([label, value]) => (
                <div key={label} className="ak-home-hero-metric">
                  <span>{label}</span>
                  <strong>{value}</strong>
                </div>
              ))}
            </div>
            <div className="ak-home-trust-tags ak-home-trust-tags-on-dark">
              {copy.hero.trust.map((item) => <span key={item}>{item}</span>)}
            </div>
          </div>
        </div>
      </section>

      <section className="ak-home-trust-strip">
        {copy.trustStrip.map((item) => <span key={item}>{item}</span>)}
      </section>

      <section className="ak-home-section">
        <div className="ak-home-heading centered">
          <p className="ak-home-eyebrow">{copy.howItWorks.badge}</p>
          <h2>{copy.howItWorks.title}</h2>
        </div>
        <div className="ak-home-step-grid">
          {copy.howItWorks.steps.map((step) => (
            <article key={step.index} className="ak-home-step-card">
              <span className="ak-home-step-index">{step.index}</span>
              <h3>{step.title}</h3>
              <p>{step.description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="ak-home-analytics-band" id="analytics">
        <div className="ak-home-analytics-grid">
          <div className="ak-home-analytics-copy">
            <p className="ak-home-eyebrow light">{copy.analytics.badge}</p>
            <h2>{copy.analytics.title}</h2>
            <p>{copy.analytics.body}</p>
            <div className="ak-home-analytics-points">
              {copy.analytics.points.map(([title, body]) => (
                <div key={title}>
                  <strong>{title}</strong>
                  <span>{body}</span>
                </div>
              ))}
            </div>
          </div>
          <div className="ak-home-analytics-panel">
            <div className="ak-home-media-shell dark">
              <img
                src={ANALYTICS_IMAGE}
                alt="Akademio analytics interface"
                className="ak-home-media-image"
              />
            </div>
          </div>
        </div>
      </section>

      <section className="ak-home-section" id="features">
        <div className="ak-home-heading centered">
          <p className="ak-home-eyebrow">{copy.features.badge}</p>
          <h2>{copy.features.title}</h2>
          <p>{copy.features.subtitle}</p>
        </div>
        <div className="ak-home-feature-grid">
          {featureCards.map(({ title, description, Icon }) => (
            <article key={title} className="ak-home-feature-card">
              <span className="ak-home-feature-icon">
                <Icon className="ak-home-feature-icon-svg" />
              </span>
              <h3>{title}</h3>
              <p>{description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="ak-home-section ak-home-security-shell" id="security">
        <div className="ak-home-security-grid">
          <div className="ak-home-security-visual">
            <div className="ak-home-media-shell">
              <img
                src={SECURITY_IMAGE}
                alt="Security controls preview"
                className="ak-home-media-image"
              />
            </div>
          </div>
          <div className="ak-home-security-copy">
            <p className="ak-home-eyebrow">{copy.governance.badge}</p>
            <h2>{copy.governance.title}</h2>
            <div className="ak-home-security-list">
              {copy.governance.items.map(([title, description]) => (
                <article key={title} className="ak-home-security-item">
                  <span className="ak-home-security-mark" />
                  <div>
                    <h3>{title}</h3>
                    <p>{description}</p>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </div>
      </section>

      <section className="ak-home-section">
        <div className="ak-home-heading centered">
          <p className="ak-home-eyebrow">{copy.comparison.badge}</p>
          <h2>{copy.comparison.title}</h2>
          <p>{copy.comparison.subtitle}</p>
        </div>
        <div className="ak-home-table-wrap">
          <table className="ak-home-compare-table">
            <thead>
              <tr>
                {copy.comparison.headers.map((header) => <th key={header}>{header}</th>)}
              </tr>
            </thead>
            <tbody>
              {copy.comparison.rows.map((row) => (
                <tr key={row[0]}>
                  {row.map((cell) => <td key={cell}>{cell}</td>)}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section className="ak-home-section ak-home-section-alt" id="pricing">
        <div className="ak-home-heading centered">
          <p className="ak-home-eyebrow">{copy.pricing.badge}</p>
          <h2>{copy.pricing.title}</h2>
          <p>{copy.pricing.subtitle}</p>
        </div>
        <div className="ak-home-pricing-grid">
          {copy.pricing.plans.map((plan) => (
            <article key={plan.name} className={`ak-home-pricing-card ${plan.featured ? 'featured' : ''}`}>
              {plan.featured && <span className="ak-home-pricing-badge">{copy.pricing.featuredBadge}</span>}
              <h3>{plan.name}</h3>
              <strong className="ak-home-price">{plan.price}</strong>
              <p>{plan.description}</p>
              <ul>
                {plan.features.map((feature) => (
                  <li key={feature}>{feature}</li>
                ))}
              </ul>
              <a href="/#demo-form" className={`btn ${plan.featured ? 'btn-brand' : 'btn-brand-outline-color'} ak-home-plan-btn`}>
                {plan.featured ? copy.pricing.buttonFeatured : copy.pricing.buttonDefault}
              </a>
            </article>
          ))}
        </div>
      </section>

      <section className="ak-home-section" id="faq">
        <div className="ak-home-heading centered">
          <p className="ak-home-eyebrow">{copy.faq.badge}</p>
          <h2>{copy.faq.title}</h2>
        </div>
        <div className="ak-home-faq-list">
          {copy.faq.items.map(([question, answer], index) => (
            <article key={question} className={`ak-home-faq-card ${openFaqIndex === index ? 'is-open' : ''}`}>
              <button
                type="button"
                className="ak-home-faq-toggle"
                aria-expanded={openFaqIndex === index}
                onClick={() => { setOpenFaqIndex(openFaqIndex === index ? -1 : index); }}
              >
                <h3>{question}</h3>
                <span className="ak-home-faq-icon" aria-hidden="true">
                  {openFaqIndex === index ? '-' : '+'}
                </span>
              </button>
              <div className="ak-home-faq-body">
                <p>{answer}</p>
              </div>
            </article>
          ))}
        </div>
      </section>

      <section className="ak-home-cta-band" id="demo-form">
        <div className="ak-home-cta-grid">
          <div className="ak-home-cta-copy">
            <p className="ak-home-eyebrow light">{copy.cta.badge}</p>
            <h2>{copy.cta.title}</h2>
            <p>{copy.cta.body}</p>
            <div className="ak-home-cta-points">
              {copy.cta.points.map((point) => (
                <div key={point} className="ak-home-cta-point">
                  <span className="ak-home-cta-mark">•</span>
                  <span>{point}</span>
                </div>
              ))}
            </div>
          </div>
          <div className="ak-home-cta-form-card">
            <div className="ak-home-form-row two">
              <label>
                <span>{copy.cta.labels.name}</span>
                <input type="text" placeholder={copy.cta.placeholders.name} readOnly />
              </label>
              <label>
                <span>{copy.cta.labels.org}</span>
                <input type="text" placeholder={copy.cta.placeholders.org} readOnly />
              </label>
            </div>
            <div className="ak-home-form-row">
              <label>
                <span>{copy.cta.labels.email}</span>
                <input type="text" placeholder={copy.cta.placeholders.email} readOnly />
              </label>
            </div>
            <div className="ak-home-form-row">
              <label>
                <span>{copy.cta.labels.useCase}</span>
                <input type="text" placeholder={copy.cta.placeholders.useCase} readOnly />
              </label>
            </div>
            <a href="/signin" className="btn btn-light ak-home-form-btn">
              {copy.cta.button}
              <ArrowRightIcon className="hi-s ms-2" />
            </a>
            <small>{copy.cta.note}</small>
          </div>
        </div>
      </section>
    </div>
  );
}
