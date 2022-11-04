import React from 'react';
import { Badge } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';

export default function SharedBadge({ ownerName }) {
  const { t } = useTranslation();

  return (
    <div>
      <Badge className="rounded-pill shared-badge ms-2">
        <span>{ t('room.shared_by')}
          <strong>{ ownerName }</strong>
        </span>
      </Badge>
    </div>
  );
}

SharedBadge.propTypes = {
  ownerName: PropTypes.string.isRequired,
};
