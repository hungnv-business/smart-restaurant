import {computed, effect, Injectable, signal} from '@angular/core';
import {Subject} from 'rxjs';

export interface layoutConfig {
    preset: string;
    primary: string;
    surface: string | undefined | null;
    darkTheme: boolean;
    menuMode: string;
    menuTheme: string;
}

interface LayoutState {
    staticMenuDesktopInactive?: boolean;
    overlayMenuActive?: boolean;
    configSidebarVisible: boolean;
    staticMenuMobileActive?: boolean;
    menuHoverActive?: boolean;
    sidebarActive: boolean;
    anchored: boolean;
    overlaySubmenuActive: boolean;
    rightMenuVisible: boolean;
    searchBarActive: boolean;
}

interface MenuChangeEvent {
    key: string;
    routeEvent?: boolean;
}

@Injectable({
    providedIn: 'root'
})
export class LayoutService {
    _config: layoutConfig = {
        preset: 'Aura',
        primary: 'blue',
        surface: null,
        darkTheme: false,
        menuMode: 'static',
        menuTheme: 'light',
    };

    _state: LayoutState = {
        staticMenuDesktopInactive: false,
        overlayMenuActive: false,
        rightMenuVisible: false,
        configSidebarVisible: false,
        staticMenuMobileActive: false,
        menuHoverActive: false,
        searchBarActive: false,
        sidebarActive: false,
        anchored: false,
        overlaySubmenuActive: false
    };

    bodyBackgroundPalette = {
        light: {
            noir: 'linear-gradient(180deg, #F4F4F5 0%, rgba(212, 212, 216, 0.12) 100%)',
            blue: 'linear-gradient(180deg, #e0e7f5 0%, rgba(170, 194, 239, 0.06) 111.26%)',
            green: 'linear-gradient(180deg, #e0f5e1 0%, rgba(170, 239, 172, 0.06) 111.26%)',
            violet: 'linear-gradient(180deg, #e9e0f5 0%, rgba(198, 170, 239, 0.06) 111.26%)',
            orange: 'linear-gradient(180deg, #f5e9e0 0%, rgba(239, 199, 170, 0.06) 111.26%)',
            rose: 'linear-gradient(180deg, #f5e0e3 0%, rgba(239, 170, 180, 0.06) 111.26%)',
            cyan: 'linear-gradient(180deg, #e0f2f5 0%, rgba(170, 229, 239, 0.06) 111.26%)',
            pink: 'linear-gradient(180deg, #f5e0eb 0%, rgba(239, 170, 205, 0.06) 111.26%)',
            red: 'linear-gradient(180deg, #f5e0e0 0%, rgba(239, 170, 170, 0.06) 111.26%)',
            amber: 'linear-gradient(180deg, #f5ede0 0%, rgba(239, 214, 170, 0.06) 111.26%)',
            yellow: 'linear-gradient(180deg, #f5f0e0 0%, rgba(239, 222, 170, 0.06) 111.26%)',
            lime: 'linear-gradient(180deg, #edf5e0 0%, rgba(212, 239, 170, 0.06) 111.26%)',
            emerald: 'linear-gradient(180deg, #e0f5ee 0%, rgba(170, 239, 216, 0.06) 111.26%)',
            teal: 'linear-gradient(180deg, #e0f5f3 0%, rgba(170, 239, 231, 0.06) 111.26%)',
            sky: 'linear-gradient(180deg, #e0eef5 0%, rgba(170, 217, 239, 0.06) 111.26%)',
            purple: 'linear-gradient(180deg, #ebe0f5 0%, rgba(206, 170, 239, 0.06) 111.26%)',
            fuchsia: 'linear-gradient(180deg, #f2e0f5 0%, rgba(230, 170, 239, 0.06) 111.26%)',
            indigo: 'linear-gradient(180deg, #e0e1f5 0%, rgba(170, 171, 239, 0.06) 111.26%)'
        },
        dark: {
            noir: '#09090b',
            blue: '#000C23',
            green: '#00231B',
            violet: '#0E0023',
            orange: '#231500',
            rose: '#230023',
            cyan: '#001E23',
            pink: '#230012',
            red: '#230000',
            amber: '#231600',
            yellow: '#231B00',
            lime: '#152300',
            emerald: '#002318',
            teal: '#00231F',
            sky: '#001823',
            purple: '#120023',
            fuchsia: '#1F0023',
            indigo: '#000123'
        }
    };

    layoutConfig = signal<layoutConfig>(this._config);

    layoutState = signal<LayoutState>(this._state);

    private configUpdate = new Subject<layoutConfig>();

    private overlayOpen = new Subject<any>();

    private menuSource = new Subject<MenuChangeEvent>();

    private resetSource = new Subject();

    menuSource$ = this.menuSource.asObservable();

    resetSource$ = this.resetSource.asObservable();

    configUpdate$ = this.configUpdate.asObservable();

    overlayOpen$ = this.overlayOpen.asObservable();

    isDarkTheme = computed(() => this.layoutConfig().darkTheme);

    isSidebarActive = computed(() => this.layoutState().overlayMenuActive || this.layoutState().staticMenuMobileActive || this.layoutState().overlaySubmenuActive);

    isSlim = computed(() => this.layoutConfig().menuMode === 'slim');

    isHorizontal = computed(() => this.layoutConfig().menuMode === 'horizontal');

    isOverlay = computed(() => this.layoutConfig().menuMode === 'overlay');

    isCompact = computed(() => this.layoutConfig().menuMode === 'compact');

    isStatic = computed(() => this.layoutConfig().menuMode === 'static');

    isReveal = computed(() => this.layoutConfig().menuMode === 'reveal');

    isDrawer = computed(() => this.layoutConfig().menuMode === 'drawer');

    transitionComplete = signal<boolean>(false);

    isSidebarStateChanged = computed(() => {
        const layoutConfig = this.layoutConfig();
        return layoutConfig.menuMode === 'horizontal' || layoutConfig.menuMode === 'slim' || layoutConfig.menuMode === 'slim-plus';
    });

    private initialized = false;

    constructor() {
        effect(() => {
            const config = this.layoutConfig();
            if (config) {
                this.onConfigUpdate();
            }
        });

        effect(() => {
            const config = this.layoutConfig();

            if (!this.initialized || !config) {
                this.initialized = true;
                return;
            }

            this.handleDarkModeTransition(config);
        });

        effect(() => {
            this.isSidebarStateChanged() && this.reset();
        });
    }

    private handleDarkModeTransition(config: layoutConfig): void {
        const supportsViewTransition = 'startViewTransition' in document;

        if (supportsViewTransition) {
            this.startViewTransition(config);
        } else {
            this.toggleDarkMode(config);
            this.onTransitionEnd();
        }
    }

    private startViewTransition(config: layoutConfig): void {
        const transition = (document as any).startViewTransition(() => {
            this.toggleDarkMode(config);
        });

        transition.ready
            .then(() => {
                this.onTransitionEnd();
            })
            .catch(() => {
            });
    }

    toggleDarkMode(config?: layoutConfig): void {
        const _config = config || this.layoutConfig();
        if (_config.darkTheme) {
            document.documentElement.classList.add('app-dark');
        } else {
            document.documentElement.classList.remove('app-dark');
        }
    }

    private onTransitionEnd() {
        this.transitionComplete.set(true);
        setTimeout(() => {
            this.transitionComplete.set(false);
        });
    }

    toggleConfigSidebar() {
        if (this.isSidebarActive()) {
            this.updateLayoutState({
                overlayMenuActive: false,
                overlaySubmenuActive: false,
                staticMenuMobileActive: false,
                menuHoverActive: false,
                configSidebarVisible: false
            });
        }
        this.updateLayoutState({
            configSidebarVisible: true
        });
    }

    updateLayoutState(newState: Partial<any>) {
        this.layoutState.update((prev) => ({
            ...prev,
            ...newState
        }));
    }

    onMenuToggle() {
        if (this.isOverlay()) {
            this.layoutState.update((prev) => ({...prev, overlayMenuActive: !this.layoutState().overlayMenuActive}));

            if (this.layoutState().overlayMenuActive) {
                this.overlayOpen.next(null);
            }
        }

        if (this.isDesktop()) {
            this.layoutState.update((prev) => ({
                ...prev,
                staticMenuDesktopInactive: !this.layoutState().staticMenuDesktopInactive
            }));
        } else {
            this.layoutState.update((prev) => ({
                ...prev,
                staticMenuMobileActive: !this.layoutState().staticMenuMobileActive
            }));

            if (this.layoutState().staticMenuMobileActive) {
                this.overlayOpen.next(null);
            }
        }
    }

    onConfigUpdate() {
        this._config = {...this.layoutConfig()};
        this.configUpdate.next(this.layoutConfig());
    }

    onMenuStateChange(event: MenuChangeEvent) {
        this.menuSource.next(event);
    }

    reset() {
        this.resetSource.next(true);
    }

    onOverlaySubmenuOpen() {
        this.overlayOpen.next(null);
    }

    showConfigSidebar() {
        this.updateLayoutState({configSidebarVisible: true});
    }

    hideConfigSidebar() {
        this.updateLayoutState({configSidebarVisible: false});
    }

    toggleRightMenu() {
        this.updateLayoutState({rightMenuVisible: !this.layoutState().rightMenuVisible});
    }

    isDesktop() {
        return window.innerWidth > 991;
    }

    isMobile() {
        return !this.isDesktop();
    }

    updateBodyBackground(color: string) {
        const root = document.documentElement;
        const colorScheme: any = this.isDarkTheme() ? this.bodyBackgroundPalette.dark : this.bodyBackgroundPalette.light;
        root.style.setProperty('--surface-ground', colorScheme[color]);
    }
}
