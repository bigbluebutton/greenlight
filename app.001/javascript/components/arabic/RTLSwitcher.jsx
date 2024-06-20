import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import i18n from '../../i18n';

export default function RTLSwitcher() {
  const { t } = useTranslation();
  const [isRTL, setIsRTL] = useState(false);

  useEffect(() => {
    document.documentElement.dir = isRTL ? 'rtl' : 'ltr';
    i18n.changeLanguage(isRTL ? 'ar' : 'en');
  }, [isRTL]);

  const toggleDirection = () => {
    setIsRTL(!isRTL);
  };

  return (
    <div>
      <button onClick={toggleDirection} className="btn btn-info" type="submit">
        {t(isRTL ? 'switch_to_ltr' : 'switch_to_rtl')}
      </button>
    </div>
  );
}

