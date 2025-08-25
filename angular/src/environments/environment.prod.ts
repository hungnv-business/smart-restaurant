export const environment = {
  production: true,
  hmr: false,
  application: {
    baseUrl: 'https://smartrestaurant.vn',
    name: 'SmartRestaurant',
    logoUrl: '/layout/images/logo-white.svg',
  },
  oAuthConfig: {
    issuer: 'https://api.smartrestaurant.vn',
    redirectUri: location.origin,
    clientId: 'SmartRestaurant_Angular',
    responseType: 'form',
    scope: 'offline_access SmartRestaurant',
  },
  apis: {
    default: {
      url: 'https://api.smartrestaurant.vn',
    },
  },
};
