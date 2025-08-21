import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { Router, RouterModule, ActivatedRoute } from '@angular/router';
import { ReactiveFormsModule, FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';
import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';
import { CheckboxModule } from 'primeng/checkbox';
import { ButtonModule } from 'primeng/button';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { ToastModule } from 'primeng/toast';

// ABP Authentication
import { AuthService } from '@abp/ng.core';

// Shared Components
import { ValidationErrorComponent } from '../../shared/components/validation-error/validation-error.component';
import { ComponentBase } from '../../shared/base/component-base';

@Component({
    selector: 'app-login',
    standalone: true,
    imports: [CommonModule, RouterModule, ReactiveFormsModule, InputTextModule, PasswordModule, CheckboxModule, ButtonModule, ProgressSpinnerModule, ToastModule, ValidationErrorComponent],
    template: `
        <section class="animate-fadein animate-duration-300 animate-ease-in relative min-h-screen flex items-center justify-center">
            <div class="w-full max-w-[46rem] mx-auto px-6 lg:px-12">
                <div class="relative">
                    <div
                        class="w-full h-full inset-0 bg-white/64 dark:bg-surface-800 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rotate-[4deg] lg:rotate-[7deg] backdrop-blur-[90px] rounded-3xl shadow-[0px_87px_24px_0px_rgba(120,149,206,0.00),0px_56px_22px_0px_rgba(120,149,206,0.01),0px_31px_19px_0px_rgba(120,149,206,0.03),0px_14px_14px_0px_rgba(120,149,206,0.04),0px_3px_8px_0px_rgba(120,149,206,0.06)] dark:shadow-sm"
                    ></div>
                    <div
                        class="w-full h-full inset-0 bg-white/64 dark:bg-surface-800 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 -rotate-[4deg] lg:-rotate-[7deg] backdrop-blur-[90px] rounded-3xl shadow-[0px_87px_24px_0px_rgba(120,149,206,0.00),0px_56px_22px_0px_rgba(120,149,206,0.01),0px_31px_19px_0px_rgba(120,149,206,0.03),0px_14px_14px_0px_rgba(120,149,206,0.04),0px_3px_8px_0px_rgba(120,149,206,0.06)] dark:shadow-sm"
                    ></div>
                    <form
                        [formGroup]="loginForm"
                        (ngSubmit)="onLogin()"
                        class="space-y-8 p-8 relative z-10 bg-white/64 dark:bg-surface-800 backdrop-blur-[90px] rounded-3xl shadow-[0px_87px_24px_0px_rgba(120,149,206,0.00),0px_56px_22px_0px_rgba(120,149,206,0.01),0px_31px_19px_0px_rgba(120,149,206,0.03),0px_14px_14px_0px_rgba(120,149,206,0.04),0px_3px_8px_0px_rgba(120,149,206,0.06)]"
                    >
                        <div class="pt-8 pb-8">
                            <h1 class="text-4xl lg:text-6xl font-semibold text-surface-950 dark:text-surface-0 text-center">Đăng nhập</h1>
                        </div>
                        <div class="flex flex-col gap-2">
                            <label for="email" class="font-medium text-surface-500 dark:text-white/64">
                                Email hoặc tên đăng nhập <span class="text-red-500">*</span>
                            </label>
                            <input 
                                pInputText 
                                id="email" 
                                formControlName="email"
                                class="w-full" 
                                [class.p-invalid]="emailControl.invalid && (emailControl.dirty || emailControl.touched)"
                                placeholder="Nhập email hoặc tên đăng nhập"
                                autocomplete="username" />
                            <app-validation-error 
                                [control]="emailControl" 
                                fieldName="Email hoặc tên đăng nhập">
                            </app-validation-error>
                        </div>
                        
                        <div class="flex flex-col gap-2">
                            <label for="password" class="font-medium text-surface-500 dark:text-white/64">
                                Mật khẩu <span class="text-red-500">*</span>
                            </label>
                            <p-password 
                                id="password" 
                                formControlName="password"
                                styleClass="w-full"
                                [inputStyleClass]="passwordControl.invalid && (passwordControl.dirty || passwordControl.touched) ? 'w-full p-invalid' : 'w-full'"
                                placeholder="Nhập mật khẩu"
                                [feedback]="false"
                                [toggleMask]="true"
                                autocomplete="current-password">
                            </p-password>
                            <app-validation-error 
                                [control]="passwordControl" 
                                fieldName="Mật khẩu">
                            </app-validation-error>
                        </div>
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-2">
                                <p-checkbox 
                                    formControlName="remember" 
                                    id="remember" 
                                    binary />
                                <label for="remember" class="text-surface-500 dark:text-white/64">Nhớ đăng nhập</label>
                            </div>
                            <a routerLink="" class="font-semibold text-primary">Quên mật khẩu?</a>
                        </div>
                        <p-button 
                            type="submit"
                            styleClass="w-full mt-8" 
                            [loading]="isLoading"
                            [disabled]="loginForm.invalid || isLoading"
                            rounded>
                            Đăng nhập
                        </p-button>
                        <div class="flex items-center justify-center gap-2">
                            <span class="text-surface-500 dark:text-white/64">Cần hỗ trợ?</span>
                            <a routerLink="" class="text-primary">Liên hệ quản lý</a>
                        </div>
                    </form>
                </div>
            </div>
        </section>
        
        <!-- Loading overlay -->
        @if (isLoading) {
            <div class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50">
                <div class="bg-white dark:bg-surface-800 rounded-2xl p-6 shadow-2xl text-center">
                    <p-progressSpinner></p-progressSpinner>
                    <p class="mt-4 text-surface-600 dark:text-surface-300 font-medium">Đang đăng nhập...</p>
                </div>
            </div>
        }
        
        <!-- Toast messages for login page -->
        <p-toast position="bottom-left"></p-toast>
    `
})
export class LoginComponent extends ComponentBase implements OnInit {
    loginForm: FormGroup;
    isLoading: boolean = false;
    private returnUrl: string = '/';
    
    constructor(
        private fb: FormBuilder,
        private authService: AuthService,
        private router: Router,
        private route: ActivatedRoute
    ) {
        super();
        this.loginForm = this.createForm();
    }

    ngOnInit() {
        // Get return URL from route parameters or default to '/'
        this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/';
        
        // Check if user is already logged in
        if (this.authService.isAuthenticated) {
            this.router.navigate([this.returnUrl]);
        }
    }
    
    private createForm(): FormGroup {
        return this.fb.group({
            email: ['', [Validators.required]],
            password: ['', [Validators.required, Validators.minLength(3)]],
            remember: [false]
        });
    }
    
    // Getter methods for form controls using ComponentBase
    get emailControl(): FormControl {
        return this.getFormControl(this.loginForm, 'email');
    }
    
    get passwordControl(): FormControl {
        return this.getFormControl(this.loginForm, 'password');
    }

    onLogin() {
        // Use ComponentBase validation method
        if (!this.validateForm(this.loginForm, 'Vui lòng nhập đầy đủ thông tin đăng nhập')) {
            return;
        }

        this.isLoading = true;
        const formValue = this.loginForm.value;

        // Use ABP Authentication Service
        this.authService.login({
            username: formValue.email,
            password: formValue.password,
            rememberMe: formValue.remember
        }).subscribe({
            next: () => {
                this.isLoading = false;
                
                // Redirect after successful login to returnUrl or default
                this.router.navigate([this.returnUrl]);
            },
            error: (error) => {
                this.isLoading = false;
                
                if (error.status === 400) {
                    this.showError("Tài khoản hoặc mật khẩu không chính xác")
                }
            }
        });
    }

}
