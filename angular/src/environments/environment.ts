export const environment = {
  production: false,
  hmr: false,
  application: {
    baseUrl: 'http://localhost:4200',
    name: 'SmartRestaurant',
    logoUrl: '/layout/images/logo-white.svg',
  },
  oAuthConfig: {
    issuer: 'https://localhost:44346/',
    redirectUri: location.origin,
    clientId: 'SmartRestaurant_App',
    responseType: 'form',
    scope: 'offline_access SmartRestaurant',
  },
  apis: {
    default: {
      url: 'https://localhost:44346',
      rootNamespace: 'SmartRestaurant',
    },
  },
};
