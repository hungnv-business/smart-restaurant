import { Injectable } from '@angular/core';
import {
  ActivatedRouteSnapshot, CanActivate, CanActivateChild,
  Router, RouterStateSnapshot, UrlTree, CanMatch, Route, UrlSegment
} from '@angular/router';
import { OAuthService } from 'angular-oauth2-oidc';
import { PermissionService, ConfigStateService } from '@abp/ng.core';
import { Observable } from 'rxjs';
import { filter, map, switchMap, take } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class RestaurantGuard implements CanActivate, CanActivateChild, CanMatch {
  constructor(
    private readonly oauth: OAuthService,
    private readonly router: Router,
    private readonly perms: PermissionService,
    private readonly config: ConfigStateService
  ) {}

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot) {
    return this.check(state.url, route.data?.['permission']);
  }

  canActivateChild(route: ActivatedRouteSnapshot, state: RouterStateSnapshot) {
    return this.check(state.url, route.data?.['permission']);
  }

  canMatch(route: Route, segments: UrlSegment[]) {
    const url = '/' + segments.map(s => s.path).join('/');
    return this.check(url, route.data?.['permission']);
  }

  private waitPoliciesReady$() {
    // Chờ đến khi Application Configuration đã có grantedPolicies
    return this.config.getOne$('auth').pipe(
      filter(auth => !!auth && !!auth.grantedPolicies),
      take(1)
    );
  }

  private check(url: string, required?: string): Observable<boolean | UrlTree> | boolean | UrlTree {
    // 1) Yêu cầu đăng nhập
    if (!this.oauth.hasValidAccessToken()) {
      return this.router.createUrlTree(['/auth/login'], { queryParams: { returnUrl: url } });
    }

    // 2) Không yêu cầu quyền -> cho vào
    if (!required) return true;

    // 3) Đợi policies sẵn sàng rồi mới kiểm tra quyền
    return this.waitPoliciesReady$().pipe(
      switchMap(() => this.perms.getGrantedPolicy$(required).pipe(take(1))),
      map(granted =>
        granted ? true : this.router.createUrlTree(['/error/403'], { queryParams: { returnUrl: url } })
      )
    );
  }
}