import { Component, computed, OnInit, Renderer2, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavigationEnd, Router, RouterModule } from '@angular/router';
import { filter, Subscription } from 'rxjs';
import { ToastModule } from 'primeng/toast';
import { AppTopbar } from './app.topbar';
import { AppSidebar } from './app.sidebar';
import { LayoutService } from '../service/layout.service';
import { AppBreadcrumb } from './app.breadcrumb';
import { AppFooter } from './app.footer';
import { AppConfigurator } from './app.configurator';
import { AppRightMenu } from './app.rightmenu';
import { AppSearch } from './app.search';

/**
 * Vietnamese Restaurant Layout Component (Component Layout Nhà hàng Việt Nam)
 *
 * Extends Poseidon layout with restaurant-specific customizations:
 * - Vietnamese restaurant menu items and navigation
 * - Touch-friendly tablet-first design
 * - Restaurant color scheme integration
 * - ABP routing integration for restaurant workflows
 */
@Component({
  selector: 'app-restaurant-layout',
  standalone: true,
  imports: [
    CommonModule,
    ToastModule,
    AppTopbar,
    AppSidebar,
    RouterModule,
    AppBreadcrumb,
    AppFooter,
    AppConfigurator,
    AppRightMenu,
    AppSearch,
  ],
  template: `
    <div class="layout-wrapper restaurant-theme vietnamese-restaurant" [ngClass]="containerClass()">
      <!-- Vietnamese Restaurant Sidebar Navigation -->
      <div app-sidebar class="restaurant-sidebar"></div>

      <div class="layout-content-wrapper">
        <div class="layout-content-wrapper-inside">
          <!-- Vietnamese Restaurant Top Bar -->
          <div app-topbar class="restaurant-topbar"></div>

          <!-- Main Restaurant Content Area -->
          <div class="layout-content restaurant-content">
            <!-- Vietnamese Breadcrumb Navigation -->
            <div app-breadcrumb class="restaurant-breadcrumb"></div>

            <!-- Restaurant Feature Routes -->
            <router-outlet></router-outlet>
          </div>

          <!-- Vietnamese Restaurant Footer -->
          <div app-footer class="restaurant-footer"></div>
        </div>
      </div>

      <!-- Poseidon Components -->
      <app-configurator />
      <div app-search></div>
      <div app-rightmenu></div>

      <!-- Layout State Overlay for Mobile/Tablet -->
      <div class="layout-mask" [ngClass]="{ 'layout-mask-active': isOverlayActive() }"></div>

      <!-- Global Toast Messages -->
      <p-toast position="bottom-left"></p-toast>
    </div>
  `,
  styleUrls: [],
})
export class RestaurantLayoutComponent implements OnInit, OnDestroy {
  overlayMenuOpenSubscription: Subscription = new Subscription();
  menuOutsideClickListener: any;

  constructor(
    public layoutService: LayoutService,
    public renderer: Renderer2,
    public router: Router
  ) {
    this.overlayMenuOpenSubscription = this.layoutService.overlayOpen$.subscribe(() => {
      if (!this.menuOutsideClickListener) {
        this.menuOutsideClickListener = this.renderer.listen('document', 'click', event => {
          const layoutWrapper = document.querySelector('.layout-wrapper');
          const isOutsideClicked = !(
            event.target.isSameNode(layoutWrapper) || layoutWrapper?.contains(event.target)
          );
          if (isOutsideClicked) {
            this.hideMenu();
          }
        });
      }
    });

    this.router.events.pipe(filter(event => event instanceof NavigationEnd)).subscribe(() => {
      this.hideMenu();
    });
  }

  ngOnInit() {
    // Initialize Vietnamese restaurant layout configuration
    this.initializeRestaurantLayout();
  }

  /**
   * Initialize Vietnamese restaurant-specific layout settings
   */
  private initializeRestaurantLayout() {
    // Ensure blue theme is selected for restaurant aesthetic
    if (this.layoutService.layoutConfig().primary !== 'blue') {
      this.layoutService.layoutConfig.update(config => ({
        ...config,
        primary: 'blue',
      }));
    }

    // Ensure static menu mode for tablet-first usage
    if (this.layoutService.layoutConfig().menuMode !== 'static') {
      this.layoutService.layoutConfig.update(config => ({
        ...config,
        menuMode: 'static',
      }));
    }
  }

  containerClass() {
    return {
      'layout-overlay': this.layoutService.isOverlay(),
      'layout-static': this.layoutService.isStatic(),
      'layout-static-inactive':
        this.layoutService.layoutState().staticMenuDesktopInactive && this.layoutService.isStatic(),
      'layout-overlay-active': this.layoutService.layoutState().overlayMenuActive,
      'layout-mobile-active': this.layoutService.layoutState().staticMenuMobileActive,
      'p-input-filled': true,
      'p-ripple-disabled': false,
      'layout-sidebar-active': this.layoutService.layoutState().sidebarActive,
      'layout-sidebar-anchored': this.layoutService.layoutState().anchored,
      'restaurant-layout': true, // Restaurant-specific class
      'blue-theme': true, // Restaurant blue theme
    };
  }

  isOverlayActive(): boolean {
    return (
      this.layoutService.layoutState().overlayMenuActive ||
      this.layoutService.layoutState().staticMenuMobileActive
    );
  }

  hideMenu() {
    this.layoutService.updateLayoutState({
      overlayMenuActive: false,
      staticMenuMobileActive: false,
    });
    this.unBindMenuOutsideClickListener();
  }

  unBindMenuOutsideClickListener() {
    if (this.menuOutsideClickListener) {
      this.menuOutsideClickListener();
      this.menuOutsideClickListener = null;
    }
  }

  ngOnDestroy() {
    if (this.overlayMenuOpenSubscription) {
      this.overlayMenuOpenSubscription.unsubscribe();
    }

    if (this.menuOutsideClickListener) {
      this.menuOutsideClickListener();
    }
  }
}
