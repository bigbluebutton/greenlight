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
import { Dropdown } from 'react-bootstrap';
import { EllipsisVerticalIcon } from '@heroicons/react/24/outline';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';

// A fixed menu is positioned against the viewport, so a scrolling table does not clip it.
const POPPER_CONFIG = { strategy: 'fixed' };

// The ⋮ menu of a table row. The toggle is a button named after its row.
export default function RowActionsDropdown({ name, children }) {
  const { t } = useTranslation();
  // React escapes the attribute itself; escaped twice, an apostrophe would be read out as "&#39;".
  const label = t('row_actions', { name, interpolation: { escapeValue: false } });

  return (
    <Dropdown className="float-end" align="end">
      <Dropdown.Toggle variant="link" className="row-actions-toggle" aria-label={label}>
        <EllipsisVerticalIcon className="hi-s" aria-hidden="true" />
      </Dropdown.Toggle>
      <Dropdown.Menu className="row-actions-menu" popperConfig={POPPER_CONFIG}>
        {children}
      </Dropdown.Menu>
    </Dropdown>
  );
}

RowActionsDropdown.propTypes = {
  name: PropTypes.string.isRequired,
  children: PropTypes.node.isRequired,
};
