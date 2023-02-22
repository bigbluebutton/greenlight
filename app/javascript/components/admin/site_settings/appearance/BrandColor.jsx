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
import { Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import BrandColorPopover from './BrandColorPopover';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';

export default function BrandColor() {
  const { t } = useTranslation();
  const { data: colors } = useSiteSettings(['PrimaryColor', 'PrimaryColorLight']);

  return (
    <div className="mb-3">
      <h5> { t('admin.site_settings.appearance.brand_color')} </h5>
      <Stack direction="horizontal">
        <BrandColorPopover
          name="PrimaryColor"
          btnName={t('admin.site_settings.appearance.regular')}
          btnVariant="brand"
          initialColor={colors?.PrimaryColor}
        />
        <BrandColorPopover
          name="PrimaryColorLight"
          btnName={t('admin.site_settings.appearance.lighten')}
          btnVariant="brand-light"
          initialColor={colors?.PrimaryColorLight}
        />
      </Stack>
    </div>
  );
}
