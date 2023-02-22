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
