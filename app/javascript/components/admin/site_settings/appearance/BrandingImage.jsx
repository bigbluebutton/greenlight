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
import { Card, Button } from 'react-bootstrap';
import { CloudArrowUpIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';
import FilesDragAndDrop from '../../../shared_components/utilities/FilesDragAndDrop';
import useDeleteBrandingImage from '../../../../hooks/mutations/admin/site_settings/useDeleteBrandingImage';
import { IMAGE_MAX_FILE_COEFF, IMAGE_SUPPORTED_EXTENSIONS } from '../../../../helpers/FileValidationHelper';

export default function BrandingImage() {
  const { t } = useTranslation();
  const updateSiteSetting = useUpdateSiteSetting('BrandingImage');
  const updateBrandingImage = useDeleteBrandingImage();

  return (
    <div className="mb-3">
      <h5> { t('admin.site_settings.appearance.brand_image') } </h5>
      <FilesDragAndDrop
        numOfFiles={1}
        onDrop={(files) => updateSiteSetting.mutate(files[0])}
        formats={IMAGE_SUPPORTED_EXTENSIONS}
      >
        <Card className="border border-2 border-whitesmoke mt-3 text-center">
          <label htmlFor="file" className="presentation-upload">
            <Card.Body className="text-secondary cursor-pointer">
              <div className="icon-circle rounded-circle d-block mx-auto mb-3">
                <CloudArrowUpIcon className="hi-l text-brand d-block mx-auto pt-4" />
              </div>
              <input
                id="file"
                className="d-none"
                type="file"
                onChange={(e) => updateSiteSetting.mutate(e.target.files[0])}
                accept=".jpg,.png,.svg"
              />
              <Card.Title className="text-brand">
                { t('admin.site_settings.appearance.click_to_upload') }
                <span className="fs-5 fw-normal text-muted">
                  { t('admin.site_settings.appearance.drag_and_drop') }
                </span>
              </Card.Title>
              <span className="text-muted">
                { t('admin.site_settings.appearance.upload_brand_image_description', { size: `${IMAGE_MAX_FILE_COEFF} MB` }) }
              </span>
            </Card.Body>
          </label>
        </Card>
      </FilesDragAndDrop>
      <Button
        variant="delete"
        className="btn-sm my-4"
        onClick={() => updateBrandingImage.mutate()}
      > { t('admin.site_settings.appearance.remove_branding_image') }
      </Button>
    </div>
  );
}
