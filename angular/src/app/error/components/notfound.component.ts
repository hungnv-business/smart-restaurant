import {Component, inject} from '@angular/core';
import {RouterModule} from '@angular/router';
import {LayoutService} from '@/layout/service/layout.service';

@Component({
    selector: 'app-notfound',
    standalone: true,
    imports: [RouterModule],
    template: `
        <section
            class="animate-fadein animate-duration-300 animate-ease-in relative min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-500 to-purple-600">
            <div class="landing-container mx-auto relative z-10 px-12">
                <div class="relative mt-24 max-w-[46rem] mx-auto">
                    <div
                        class="w-full h-full inset-0 bg-white/64 dark:bg-surface-800 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rotate-[4deg] lg:rotate-[7deg] backdrop-blur-[90px] rounded-3xl shadow-[0px_87px_24px_0px_rgba(120,149,206,0.00),0px_56px_22px_0px_rgba(120,149,206,0.01),0px_31px_19px_0px_rgba(120,149,206,0.03),0px_14px_14px_0px_rgba(120,149,206,0.04),0px_3px_8px_0px_rgba(120,149,206,0.06)] dark:shadow-sm"
                    ></div>
                    <div
                        class="w-full h-full inset-0 bg-white/64 dark:bg-surface-800 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 -rotate-[4deg] lg:-rotate-[7deg] backdrop-blur-[90px] rounded-3xl shadow-[0px_87px_24px_0px_rgba(120,149,206,0.00),0px_56px_22px_0px_rgba(120,149,206,0.01),0px_31px_19px_0px_rgba(120,149,206,0.03),0px_14px_14px_0px_rgba(120,149,206,0.04),0px_3px_8px_0px_rgba(120,149,206,0.06)] dark:shadow-sm"
                    ></div>
                    <div
                        class="flex flex-col items-center p-8 py-20 relative z-10 bg-white/64 dark:bg-surface-800 backdrop-blur-[90px] rounded-3xl shadow-[0px_87px_24px_0px_rgba(120,149,206,0.00),0px_56px_22px_0px_rgba(120,149,206,0.01),0px_31px_19px_0px_rgba(120,149,206,0.03),0px_14px_14px_0px_rgba(120,149,206,0.04),0px_3px_8px_0px_rgba(120,149,206,0.06)]"
                    >
                        <h2 class="text-4xl lg:text-6xl font-semibold text-surface-950 dark:text-surface-0 mt-8 text-center">
                            Không tìm thấy trang</h2>
                        <p class="lg:text-xl text-surface-500 dark:text-white/64 mt-4 text-center">
                            Trang bạn đang tìm kiếm không tồn tại hoặc đã bị di chuyển.</p>
                        <a routerLink="/" class="mt-8 inline-flex items-center justify-center px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg transition-colors duration-200">
                            <i class="pi pi-home mr-2"></i>
                            Về trang chủ
                        </a>
                    </div>
                </div>
            </div>
        </section>`
})
export class NotfoundComponent {
    layoutService = inject(LayoutService);
}