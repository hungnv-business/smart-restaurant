import { Environment } from '@abp/ng.core';

const baseUrl = 'http://localhost:4200';

export const environment = {
  production: true,
  application: {
    baseUrl,
    name: 'SmartRestaurant',
    logoUrl: '',
  },
  oAuthConfig: {
    issuer: 'https://localhost:44346/',
    redirectUri: baseUrl,
    clientId: 'SmartRestaurant_App',
    responseType: 'code',
    scope: 'offline_access SmartRestaurant',
    requireHttps: true
  },
  apis: {
    default: {
      url: 'https://localhost:44346',
      rootNamespace: 'SmartRestaurant',
    },
  },
} as Environment;
