import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

// PrimeNG Modules
import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';
import { CheckboxModule } from 'primeng/checkbox';
import { ButtonModule } from 'primeng/button';
import { ToastModule } from 'primeng/toast';
import { ProgressSpinnerModule } from 'primeng/progressspinner';

// Shared Components
import { ValidationErrorComponent } from './components/validation-error/validation-error.component';

const SHARED_COMPONENTS = [ValidationErrorComponent];

const PRIMENG_MODULES = [
  InputTextModule,
  PasswordModule,
  CheckboxModule,
  ButtonModule,
  ToastModule,
  ProgressSpinnerModule,
];

@NgModule({
  imports: [
    CommonModule,
    ReactiveFormsModule,
    FormsModule,
    RouterModule,
    ...PRIMENG_MODULES,
    ...SHARED_COMPONENTS,
  ],
  declarations: [],
  exports: [
    CommonModule,
    ReactiveFormsModule,
    FormsModule,
    RouterModule,
    ...PRIMENG_MODULES,
    ...SHARED_COMPONENTS,
  ],
})
export class SharedModule {}
