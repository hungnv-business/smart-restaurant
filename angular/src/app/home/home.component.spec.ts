import { CoreTestingModule } from '@abp/ng.core/testing';
import { ComponentFixture, TestBed, waitForAsync } from '@angular/core/testing';
import { NgxValidateCoreModule } from '@ngx-validate/core';
import { HomeComponent } from './home.component';
import { OAuthService } from 'angular-oauth2-oidc';
import { AuthService } from '@abp/ng.core';

describe('HomeComponent', () => {
  let fixture: ComponentFixture<HomeComponent>;
  const mockOAuthService = jasmine.createSpyObj('OAuthService', ['hasValidAccessToken']);
  const mockAuthService = jasmine.createSpyObj('AuthService', ['navigateToLogin']);
  beforeEach(waitForAsync(() => {
    TestBed.configureTestingModule({
      declarations: [],
      imports: [CoreTestingModule.withConfig(), NgxValidateCoreModule, HomeComponent],
      providers: [
        /* mock providers here */
        {
          provide: OAuthService,
          useValue: mockOAuthService,
        },
        {
          provide: AuthService,
          useValue: mockAuthService,
        },
      ],
    }).compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(HomeComponent);
    fixture.detectChanges();
  });

  it('should be initiated', () => {
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('should render welcome message', () => {
    const compiled = fixture.nativeElement;
    expect(compiled.querySelector('h2').textContent).toContain('Welcome to SmartRestaurant');
  });

  it('should render card with getting started info', () => {
    const compiled = fixture.nativeElement;
    expect(compiled.querySelector('.card-title').textContent).toContain('Getting Started');
  });
});
