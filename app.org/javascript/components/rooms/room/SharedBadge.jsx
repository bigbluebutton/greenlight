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
import { Badge } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';

export default function SharedBadge({ ownerName }) {
  const { t } = useTranslation();

  return (
    <div>
      <Badge className="rounded-pill shared-badge ms-2">
        <span>{ t('room.shared_by')} {' '}
          <strong>{ ownerName }</strong>
        </span>
      </Badge>
    </div>
  );
}

SharedBadge.propTypes = {
  ownerName: PropTypes.string.isRequired,
};
