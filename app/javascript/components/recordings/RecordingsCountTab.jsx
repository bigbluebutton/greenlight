import React from 'react';
import { Badge, Stack } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';

export default function RecordingsCountTab({ count }) {
  const { t } = useTranslation();

  return (
    <Stack direction="horizontal" gap={0}>
      <span> { t('recording.recordings') } </span>
      { count > 0
        && (
          <Badge className="rounded-pill recordings-count-badge fw-normal ms-2 text-brand">
            { count }
          </Badge>
        )}
    </Stack>
  );
}

RecordingsCountTab.propTypes = {
  count: PropTypes.number,
};

RecordingsCountTab.defaultProps = {
  count: 0,
};
