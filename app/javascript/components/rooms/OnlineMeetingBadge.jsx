import React from 'react';
import { Badge } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

export default function OnlineMeetingBadge() {
  const { t } = useTranslation();

  return (
    <Badge className="rounded-pill online-badge ms-2 text-success">
      <span className="blinking-green-dot" /> online
    </Badge>
  );
}
