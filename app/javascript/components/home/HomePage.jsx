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

import {
  ArrowRightIcon
} from "@heroicons/react/24/outline";
import React, { useEffect } from "react";
import { Col, Row } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { useNavigate, useSearchParams } from "react-router-dom";
import { toast } from "react-toastify";
import { useAuth } from "../../contexts/auth/AuthProvider";
import useEnv from "../../hooks/queries/env/useEnv";

export default function HomePage() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const error = searchParams.get("error");
  const { data: env } = useEnv();

  // Redirects the user to the proper page based on signed in status and CreateRoom permission
  useEffect(() => {
    // Todo: Use PermissionChecker.
    if (
      !currentUser.stateChanging &&
      currentUser.signed_in &&
      currentUser.permissions.CreateRoom === "true"
    ) {
      navigate("/rooms");
    } else if (
      !currentUser.stateChanging &&
      currentUser.signed_in &&
      currentUser.permissions.CreateRoom === "false"
    ) {
      navigate("/home");
    }
  }, [currentUser.signed_in]);

  useEffect(() => {
    switch (error) {
      case "InviteInvalid":
        toast.error(t("toast.error.users.invalid_invite"));
        break;
      case "SignupError":
        toast.error(t("toast.error.users.signup_error"));
        break;
      default:
    }
    if (error) {
      setSearchParams(searchParams.delete("error"));
    }
  }, [error]);

  // useEffect for inviteToken
  useEffect(() => {
    const inviteToken = searchParams.get("inviteToken");

    // Environment settings not loaded
    if (!env) {
      return;
    }

    if (inviteToken && env?.EXTERNAL_AUTH) {
      const signInForm = document.querySelector(
        'form[action="/auth/openid_connect"]'
      );
      signInForm.submit();
    } else if (inviteToken && !env?.EXTERNAL_AUTH) {
      const buttons = document.querySelectorAll(".btn");
      buttons.forEach((button) => {
        if (button.textContent === "Sign Up") {
          button.click();
        }
      });
    }
  }, [searchParams, env]);

  return (
    <>
      <Row className="wide-white">
        <Col lg={10}>
          <div id="homepage-hero">
            <h1 className="my-4">{t("homepage.welcome")}</h1>
            <p className="text-muted fs-5">{t("homepage.mistaken_entry")}</p>
            <a
              href="https://tutorbees.net/"
              className="fs-5 text-link fw-bolder"
            >
              {t("homepage.learn_more")}
              <ArrowRightIcon className="hi-s ms-2" />
            </a>
          </div>
        </Col>
      </Row>
    </>
  );
}
