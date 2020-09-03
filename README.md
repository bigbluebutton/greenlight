# Greenlight

![Travis CI](https://travis-ci.org/bigbluebutton/greenlight.svg?branch=master)
![Coverage
!Status](https://coveralls.io/repos/github/bigbluebutton/greenlight/badge.svg?branch=master)
![Docker Pulls](https://img.shields.io/docker/pulls/bigbluebutton/greenlight.svg)

Greenlight is a simple front-end interface for your BigBlueButton server. At it's heart, Greenlight provides a minimalistic web-based application that allows users to:

  * Signup/Login with Google, Office365, or through the application itself.
  * Manage your account settings and user preferences.
  * Create and manage your own personal rooms ([BigBlueButton](https://github.com/bigbluebutton/bigbluebutton) sessions).
  * Invite others to your room using a simple URL.
  * View recordings and share them with others.

Interested? Try Greenlight out on our [demo server](https://demo.bigbluebutton.org/gl)!

Greenlight is also completely configurable. This means you can turn on/off features to make Greenlight fit your specific use case. For more information on Greenlight and its features, see our [documentation](http://docs.bigbluebutton.org/greenlight/gl-install.html).

For a overview of how Greenlight works, checkout our Introduction to Greenlight Video:

[![GreenLight Overview](https://img.youtube.com/vi/Hso8yLzkqj8/0.jpg)](https://youtu.be/Hso8yLzkqj8)

## Installation on a BigBlueButton Server

Greenlight is designed to work on a [BigBlueButton 2.0](https://github.com/bigbluebutton/bigbluebutton) (or later) server.

For information on installing Greenlight, checkout our [Installing Greenlight on a BigBlueButton Server](http://docs.bigbluebutton.org/greenlight/gl-install.html#installing-on-a-bigbluebutton-server) documentation.

## Source Code & Contributing

Greenlight is built using Ruby on Rails. Many developers already know Rails well, and we wanted to create both a full front-end to BigBlueButton but also a reference implementation of how to fully leverage the [BigBlueButton API](http://docs.bigbluebutton.org/dev/api.html).

We invite you to build upon Greenlight and help make it better. See [Contributing to BigBlueButton](http://docs.bigbluebutton.org/support/faq.html#contributing-to-bigbluebutton).

We invite your feedback, questions, and suggests about Greenlight too. Please post them to the [developer mailing list](https://groups.google.com/forum/#!forum/bigbluebutton-dev).




# SAML

Greenlight is a Service Provider, that connects to IdP to get authentification.

Unfortunatly, Greenlight not supported SAML out of the box. But there is a [PR Request](https://github.com/bigbluebutton/greenlight/pull/1334) thet gives needed functionality.

After all code changes merged - you should configure the SAML.

## Usefull links:
To get metadata of Greenlight use [\<Greenlight homepage Link\>/auth/saml/metadata]()

By default:
```xml
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="_4aca0f27-b0b7-435b-98a1-bc26d7148b41" entityID="http://app.example.com">
<md:SPSSODescriptor AuthnRequestsSigned="false" WantAssertionsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
<md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</md:NameIDFormat>
<md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="http://<domain>/b/auth/saml/callback" index="0" isDefault="true"/>
<md:AttributeConsumingService index="1" isDefault="true">
<md:ServiceName xml:lang="en">Required attributes</md:ServiceName>
<md:RequestedAttribute FriendlyName="Email address" Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
<md:RequestedAttribute FriendlyName="Full name" Name="name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
<md:RequestedAttribute FriendlyName="Given name" Name="first_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
<md:RequestedAttribute FriendlyName="Family name" Name="last_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" isRequired="false"/>
</md:AttributeConsumingService>
</md:SPSSODescriptor>
</md:EntityDescriptor>
```

To get metadata from IdP (in case of SimpleSamlPhp) use [\<IdP domain\>/authentication/saml/saml2/idp/metadata.php]()

Example:
```xml
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" entityID="http://localhost:8080/simplesaml/saml2/idp/metadata.php">
<md:IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
<md:KeyDescriptor use="signing">
<ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
<ds:X509Data>
<ds:X509Certificate>MIIDXTCCAkWgAwIBAgIJALmVVuDWu4NYMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwHhcNMTYxMjMxMTQzNDQ3WhcNNDgwNjI1MTQzNDQ3WjBFMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzUCFozgNb1h1M0jzNRSCjhOBnR+uVbVpaWfXYIR+AhWDdEe5ryY+CgavOg8bfLybyzFdehlYdDRgkedEB/GjG8aJw06l0qF4jDOAw0kEygWCu2mcH7XOxRt+YAH3TVHa/Hu1W3WjzkobqqqLQ8gkKWWM27fOgAZ6GieaJBN6VBSMMcPey3HWLBmc+TYJmv1dbaO2jHhKh8pfKw0W12VM8P1PIO8gv4Phu/uuJYieBWKixBEyy0lHjyixYFCR12xdh4CA47q958ZRGnnDUGFVE1QhgRacJCOZ9bd5t9mr8KLaVBYTCJo5ERE8jymab5dPqe5qKfJsCZiqWglbjUo9twIDAQABo1AwTjAdBgNVHQ4EFgQUxpuwcs/CYQOyui+r1G+3KxBNhxkwHwYDVR0jBBgwFoAUxpuwcs/CYQOyui+r1G+3KxBNhxkwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAAiWUKs/2x/viNCKi3Y6blEuCtAGhzOOZ9EjrvJ8+COH3Rag3tVBWrcBZ3/uhhPq5gy9lqw4OkvEws99/5jFsX1FJ6MKBgqfuy7yh5s1YfM0ANHYczMmYpZeAcQf2CGAaVfwTTfSlzNLsF2lW/ly7yapFzlYSJLGoVE+OHEu8g5SlNACUEfkXw+5Eghh+KzlIN7R6Q7r2ixWNFBC/jWf7NKUfJyX8qIG5md1YUeT6GBW9Bm2/1/RiO24JTaYlfLdKK9TYb8sG5B+OLab2DImG99CJ25RkAcSobWNF5zD0O6lgOo3cEdB/ksCq3hmtlC/DlLZ/D8CJ+7VuZnS1rR2naQ==</ds:X509Certificate>
</ds:X509Data>
</ds:KeyInfo>
</md:KeyDescriptor>
<md:KeyDescriptor use="encryption">
<ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
<ds:X509Data>
<ds:X509Certificate>MIIDXTCCAkWgAwIBAgIJALmVVuDWu4NYMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwHhcNMTYxMjMxMTQzNDQ3WhcNNDgwNjI1MTQzNDQ3WjBFMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzUCFozgNb1h1M0jzNRSCjhOBnR+uVbVpaWfXYIR+AhWDdEe5ryY+CgavOg8bfLybyzFdehlYdDRgkedEB/GjG8aJw06l0qF4jDOAw0kEygWCu2mcH7XOxRt+YAH3TVHa/Hu1W3WjzkobqqqLQ8gkKWWM27fOgAZ6GieaJBN6VBSMMcPey3HWLBmc+TYJmv1dbaO2jHhKh8pfKw0W12VM8P1PIO8gv4Phu/uuJYieBWKixBEyy0lHjyixYFCR12xdh4CA47q958ZRGnnDUGFVE1QhgRacJCOZ9bd5t9mr8KLaVBYTCJo5ERE8jymab5dPqe5qKfJsCZiqWglbjUo9twIDAQABo1AwTjAdBgNVHQ4EFgQUxpuwcs/CYQOyui+r1G+3KxBNhxkwHwYDVR0jBBgwFoAUxpuwcs/CYQOyui+r1G+3KxBNhxkwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAAiWUKs/2x/viNCKi3Y6blEuCtAGhzOOZ9EjrvJ8+COH3Rag3tVBWrcBZ3/uhhPq5gy9lqw4OkvEws99/5jFsX1FJ6MKBgqfuy7yh5s1YfM0ANHYczMmYpZeAcQf2CGAaVfwTTfSlzNLsF2lW/ly7yapFzlYSJLGoVE+OHEu8g5SlNACUEfkXw+5Eghh+KzlIN7R6Q7r2ixWNFBC/jWf7NKUfJyX8qIG5md1YUeT6GBW9Bm2/1/RiO24JTaYlfLdKK9TYb8sG5B+OLab2DImG99CJ25RkAcSobWNF5zD0O6lgOo3cEdB/ksCq3hmtlC/DlLZ/D8CJ+7VuZnS1rR2naQ==</ds:X509Certificate>
</ds:X509Data>
</ds:KeyInfo>
</md:KeyDescriptor>
<md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="http://localhost:8080/simplesaml/saml2/idp/SingleLogoutService.php"/>
<md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</md:NameIDFormat>
<md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="http://localhost:8080/simplesaml/saml2/idp/SSOService.php"/>
</md:IDPSSODescriptor>
</md:EntityDescriptor>
```

## Configuration and Deploy
### Configuration
#### Create .env configuration
In `greenlight` folder use command `cp sample.env .env`
#### Generating a Secret Key
Greenlight needs a secret key in order to run in production. To generate this, run:

`docker run --rm bigbluebutton/greenlight:v2 bundle exec rake secret`

Inside your .env file, set the SECRET_KEY_BASE option to the last line in this command. You don’t need to surround it in quotations.

#### Setting BigBlueButton Credentials
By default, your Greenlight instance will automatically connect to test-install.blindsidenetworks.com if no BigBlueButton credentials are specified. To set Greenlight to connect to your BigBlueButton server (the one it’s installed on), you need to give Greenlight the endpoint and the secret. 

`bbb-conf --secret`

In your .env file, set the BIGBLUEBUTTON_ENDPOINT to the URL, and set BIGBLUEBUTTON_SECRET to the secret.
#### SAML configuration
SAML configuration required configuration from both sides. 
1. Greenlight required uniq identifier of SP, that should be stored in IdP. 
The best way is to set SAML_ISSUER variable in .env and then lookup greenlight metadata from IpD.

2. Set SAML_IDP_URL variable. SAML_IDP_URL is the URL to which the authentication request should be sent. This would be on the identity provider. It can be found in the IDP's metadata in the <md:SingleSignOnService> tag. Get this tag from IdP metadata.

3. SAML_IDP_CERT_FINGERPRINT is the fingerprint of the certificate used by the IDP in sha1, for example "25:72:85:66:C9:94:22:98:36:84:11:E1:88:C7:AC:40:98:F9:E7:82"(without "). 
4. SAML_NAME_IDENTIFIER - could get from IdP metadata. by default it is "urn:oasis:names:tc:SAML:2.0:nameid-format:transient"
5. All others variables needed to map SAML response fields to user fields in the Greenlight.
To get all available fields check IdP or record network activity in developer console in your browser. Try to sign in using SAML, copy encoded SAML Response, decode it using [decoder](https://www.samltool.com/decode.php) and map values from responce by name fields to variables in .env
Example:
```xml
<samlp:Response xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="_c698df5088d9d2760948b7efefc4f82f0de07e51dc" Version="2.0" IssueInstant="2020-08-19T12:43:05Z" Destination="http://localhost/b/auth/saml/callback" InResponseTo="_7113c56a-17dd-46a6-a54d-0e293d2e457e">
    <saml:Issuer>http://localhost:8080/simplesaml/saml2/idp/metadata.php</saml:Issuer>
    <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        <ds:SignedInfo>
            <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
            <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
            <ds:Reference URI="#_c698df5088d9d2760948b7efefc4f82f0de07e51dc">
                <ds:Transforms>
                    <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
                    <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
                </ds:Transforms>
                <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
                <ds:DigestValue>4h3YTNHasNgeSn0ufPicciH/2r0=</ds:DigestValue>
            </ds:Reference>
        </ds:SignedInfo>
        <ds:SignatureValue>YhAeMinNvGlBW+Cb0vyOtkMw/Ql/MbS41Y65BsjEGxAdQ3BOc2PsUCAF8gljjRqK795KDkLFOU3ZQBvIDH1HY/zyxtv4nCesWwKHky6k+CU261oxrEl3g4Erox0bBTBfHxpScjUQeM7ANoor5kQAC1bmxUnq2W23wdnOEKrn/DGWuUEkkmibtQsSMv1z+0BV0sz0sYe5v9t/MAjJpcMKdctu7ip40kzmwFTthrIB8kYRGA6mNyT5vvYVPBat2FXqNPGwKW3g/tKsi/0ubC9TWLDWiVPkRi82hRVNTK9lkYlCtnZOKY4EQwoTzTAlNKF74AUdH+CfUtKAcWXxm2lMQw==</ds:SignatureValue>
        <ds:KeyInfo>
            <ds:X509Data>
                <ds:X509Certificate>MIIDXTCCAkWgAwIBAgIJALmVVuDWu4NYMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwHhcNMTYxMjMxMTQzNDQ3WhcNNDgwNjI1MTQzNDQ3WjBFMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzUCFozgNb1h1M0jzNRSCjhOBnR+uVbVpaWfXYIR+AhWDdEe5ryY+CgavOg8bfLybyzFdehlYdDRgkedEB/GjG8aJw06l0qF4jDOAw0kEygWCu2mcH7XOxRt+YAH3TVHa/Hu1W3WjzkobqqqLQ8gkKWWM27fOgAZ6GieaJBN6VBSMMcPey3HWLBmc+TYJmv1dbaO2jHhKh8pfKw0W12VM8P1PIO8gv4Phu/uuJYieBWKixBEyy0lHjyixYFCR12xdh4CA47q958ZRGnnDUGFVE1QhgRacJCOZ9bd5t9mr8KLaVBYTCJo5ERE8jymab5dPqe5qKfJsCZiqWglbjUo9twIDAQABo1AwTjAdBgNVHQ4EFgQUxpuwcs/CYQOyui+r1G+3KxBNhxkwHwYDVR0jBBgwFoAUxpuwcs/CYQOyui+r1G+3KxBNhxkwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAAiWUKs/2x/viNCKi3Y6blEuCtAGhzOOZ9EjrvJ8+COH3Rag3tVBWrcBZ3/uhhPq5gy9lqw4OkvEws99/5jFsX1FJ6MKBgqfuy7yh5s1YfM0ANHYczMmYpZeAcQf2CGAaVfwTTfSlzNLsF2lW/ly7yapFzlYSJLGoVE+OHEu8g5SlNACUEfkXw+5Eghh+KzlIN7R6Q7r2ixWNFBC/jWf7NKUfJyX8qIG5md1YUeT6GBW9Bm2/1/RiO24JTaYlfLdKK9TYb8sG5B+OLab2DImG99CJ25RkAcSobWNF5zD0O6lgOo3cEdB/ksCq3hmtlC/DlLZ/D8CJ+7VuZnS1rR2naQ==</ds:X509Certificate>
            </ds:X509Data>
        </ds:KeyInfo>
    </ds:Signature>
    <samlp:Status>
        <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
    </samlp:Status>
    <saml:Assertion xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xs="http://www.w3.org/2001/XMLSchema" ID="_967d4bd80ec61cb8782bef05b76d28b4a51bdec5e5" Version="2.0" IssueInstant="2020-08-19T12:43:05Z">
        <saml:Issuer>http://localhost:8080/simplesaml/saml2/idp/metadata.php</saml:Issuer>
        <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
            <ds:SignedInfo>
                <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
                <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
                <ds:Reference URI="#_967d4bd80ec61cb8782bef05b76d28b4a51bdec5e5">
                    <ds:Transforms>
                        <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
                        <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
                    </ds:Transforms>
                    <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
                    <ds:DigestValue>+adS0XQBcAPrG7TZ482tu7QDhyc=</ds:DigestValue>
                </ds:Reference>
            </ds:SignedInfo>
            <ds:SignatureValue>yXRd0mN4LrVJ70c/C3PgeZIDRAqgVogQplUIIBJGiM5b3GJk7Fe1cw5D5UzXAurh5xWi/LBlzynRUus7xuNjezgNfIwGgBEyumc5cw6va1mPkgr1jLhBMCpf43fJbHmhgmaxAtLfbYI9tsjOutSsMkJ2U/I2e9hq7sUU2f4n1oqkEqfTPl4QiM/P7/QFcZX9rJSaaVqV5ftysVi2QYizxNroTz4JMAXOyYYNbJxXwGR6E8vscNSnnotf/r8kRyUnNPYGqTWp1qd4O98NS+ox9SMXHQNQqfYD2IBQ8E8s3P+2VB+lSVt8RiEll9Ymjr0eV3/BBM6AUbjEEPUPBUSsOQ==</ds:SignatureValue>
            <ds:KeyInfo>
                <ds:X509Data>
                    <ds:X509Certificate>MIIDXTCCAkWgAwIBAgIJALmVVuDWu4NYMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwHhcNMTYxMjMxMTQzNDQ3WhcNNDgwNjI1MTQzNDQ3WjBFMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzUCFozgNb1h1M0jzNRSCjhOBnR+uVbVpaWfXYIR+AhWDdEe5ryY+CgavOg8bfLybyzFdehlYdDRgkedEB/GjG8aJw06l0qF4jDOAw0kEygWCu2mcH7XOxRt+YAH3TVHa/Hu1W3WjzkobqqqLQ8gkKWWM27fOgAZ6GieaJBN6VBSMMcPey3HWLBmc+TYJmv1dbaO2jHhKh8pfKw0W12VM8P1PIO8gv4Phu/uuJYieBWKixBEyy0lHjyixYFCR12xdh4CA47q958ZRGnnDUGFVE1QhgRacJCOZ9bd5t9mr8KLaVBYTCJo5ERE8jymab5dPqe5qKfJsCZiqWglbjUo9twIDAQABo1AwTjAdBgNVHQ4EFgQUxpuwcs/CYQOyui+r1G+3KxBNhxkwHwYDVR0jBBgwFoAUxpuwcs/CYQOyui+r1G+3KxBNhxkwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAAiWUKs/2x/viNCKi3Y6blEuCtAGhzOOZ9EjrvJ8+COH3Rag3tVBWrcBZ3/uhhPq5gy9lqw4OkvEws99/5jFsX1FJ6MKBgqfuy7yh5s1YfM0ANHYczMmYpZeAcQf2CGAaVfwTTfSlzNLsF2lW/ly7yapFzlYSJLGoVE+OHEu8g5SlNACUEfkXw+5Eghh+KzlIN7R6Q7r2ixWNFBC/jWf7NKUfJyX8qIG5md1YUeT6GBW9Bm2/1/RiO24JTaYlfLdKK9TYb8sG5B+OLab2DImG99CJ25RkAcSobWNF5zD0O6lgOo3cEdB/ksCq3hmtlC/DlLZ/D8CJ+7VuZnS1rR2naQ==</ds:X509Certificate>
                </ds:X509Data>
            </ds:KeyInfo>
        </ds:Signature>
        <saml:Subject>
            <saml:NameID SPNameQualifier="http://app.example.com" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:transient">_121761ee0de5079eabcdbb30e4b1f8b78e5adf6474</saml:NameID>
            <saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
                <saml:SubjectConfirmationData NotOnOrAfter="2020-08-19T12:48:05Z" Recipient="http://localhost/b/auth/saml/callback" InResponseTo="_7113c56a-17dd-46a6-a54d-0e293d2e457e"/>
            </saml:SubjectConfirmation>
        </saml:Subject>
        <saml:Conditions NotBefore="2020-08-19T12:42:35Z" NotOnOrAfter="2020-08-19T12:48:05Z">
            <saml:AudienceRestriction>
                <saml:Audience>http://app.example.com</saml:Audience>
            </saml:AudienceRestriction>
        </saml:Conditions>
        <saml:AuthnStatement AuthnInstant="2020-08-19T12:41:37Z" SessionNotOnOrAfter="2020-08-19T20:41:37Z" SessionIndex="_c9796530a48bef38b84e5191c2e702899a8833aeee">
            <saml:AuthnContext>
                <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:Password</saml:AuthnContextClassRef>
            </saml:AuthnContext>
        </saml:AuthnStatement>
        <saml:AttributeStatement>
            <saml:Attribute Name="uid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
                <saml:AttributeValue xsi:type="xs:string">1</saml:AttributeValue>
            </saml:Attribute>
            <saml:Attribute Name="eduPersonAffiliation" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
                <saml:AttributeValue xsi:type="xs:string">group1</saml:AttributeValue>
            </saml:Attribute>
            <saml:Attribute Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
                <saml:AttributeValue xsi:type="xs:string">user1@example.com</saml:AttributeValue>
            </saml:Attribute>
            <saml:Attribute Name="preferredLanguage" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
                <saml:AttributeValue xsi:type="xs:string">en</saml:AttributeValue>
            </saml:Attribute>
        </saml:AttributeStatement>
    </saml:Assertion>
</samlp:Response>
```


#### Change DB connection settings in .env file
#### Configure Nginx to Route To Greenlight
Use [documentation](https://docs.bigbluebutton.org/greenlight/gl-customize.html#4-configure-nginx-to-route-to-greenlight) 
#### Build docker image
`./scripts/image_build.sh <image name> release-v2`
#### Convigure docker-compose file for your settings
#### Start
`docker-compose up -d`

#### Stop
`docker-compose down`


#### In case of code changes:
    1. docker-compose down
    2. ./scripts/image_build.sh <image name> release-v2
    3. docker-compose up -d


## Help
use [Documentation](https://docs.bigbluebutton.org/greenlight/gl-customize.html) if you need a help