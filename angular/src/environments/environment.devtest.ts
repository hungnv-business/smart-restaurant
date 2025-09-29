import { Environment } from '@abp/ng.core';

const baseUrl = 'MY_FRONTEND_BASE_URL';
export const environment = {
  production: true,
  hmr: false,
  application: {
    baseUrl,
    name: 'SmartRestaurant',
    logoUrl: '/layout/images/logo-white.svg',
  },
  oAuthConfig: {
    issuer: 'MY_BACKEND_BASE_URL' + '/',
    redirectUri: location.origin,
    clientId: 'MY_WEB_CLIENT_ID',
    responseType: 'form',
    scope: 'offline_access SmartRestaurant',
  },
  apis: {
    default: {
      url: 'MY_BACKEND_BASE_URL',
      rootNamespace: 'SmartRestaurant',
    },
  },
} as Environment;
