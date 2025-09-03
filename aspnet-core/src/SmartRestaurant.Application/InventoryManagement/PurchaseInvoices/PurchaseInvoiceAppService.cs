using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Common;
using SmartRestaurant.InventoryManagement.PurchaseInvoices;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.Permissions;
using SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Domain.Entities;
using System.Linq.Dynamic.Core;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices
{
    /// <summary>
    /// Application Service quản lý hóa đơn mua hàng trong hệ thống nhà hàng
    /// Xử lý CRUD operations cho hóa đơn mua và các mặt hàng trong hóa đơn
    /// Bao gồm validation, authorization, business logic và quản lý stock
    /// </summary>
    [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Default)]
    public class PurchaseInvoiceAppService : ApplicationService, IPurchaseInvoiceAppService
    {
        private readonly IPurchaseInvoiceRepository _purchaseInvoiceRepository;
        private readonly IRepository<Ingredient, Guid> _ingredientRepository;
        private readonly IIngredientRepository _ingredientDetailRepository;
        private readonly PurchaseInvoiceManager _purchaseInvoiceManager;

        /// <summary>
        /// Khởi tạo PurchaseInvoiceAppService với các dependency cần thiết
        /// </summary>
        /// <param name="purchaseInvoiceRepository">Repository quản lý hóa đơn mua hàng</param>
        /// <param name="ingredientRepository">Repository cơ bản cho nguyên liệu</param>
        /// <param name="ingredientDetailRepository">Repository chi tiết cho nguyên liệu</param>
        /// <param name="purchaseInvoiceManager">Domain manager xử lý business logic hóa đơn</param>
        public PurchaseInvoiceAppService(
            IPurchaseInvoiceRepository purchaseInvoiceRepository,
            IRepository<Ingredient, Guid> ingredientRepository,
            IIngredientRepository ingredientDetailRepository,
            PurchaseInvoiceManager purchaseInvoiceManager)
        {
            _purchaseInvoiceRepository = purchaseInvoiceRepository;
            _ingredientRepository = ingredientRepository;
            _ingredientDetailRepository = ingredientDetailRepository;
            _purchaseInvoiceManager = purchaseInvoiceManager;
        }

        /// <summary>
        /// Lấy thông tin chi tiết hóa đơn mua theo ID
        /// Bao gồm thông tin các mặt hàng và chi tiết nguyên liệu
        /// </summary>
        /// <param name="id">ID của hóa đơn cần lấy</param>
        /// <returns>Thông tin chi tiết hóa đơn mua</returns>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Default)]
        public async Task<PurchaseInvoiceDto> GetAsync(Guid id)
        {
            var purchaseInvoice = await _purchaseInvoiceRepository.GetWithDetailsAsync(id);

            if (purchaseInvoice == null)
            {
                throw new EntityNotFoundException(typeof(PurchaseInvoice), id);
            }

            return ObjectMapper.Map<PurchaseInvoice, PurchaseInvoiceDto>(purchaseInvoice);
        }

        /// <summary>
        /// Tạo mới hóa đơn mua với các mặt hàng
        /// Xử lý validation, tính toán tổng tiền và cập nhật stock nguyên liệu
        /// </summary>
        /// <param name="input">Thông tin hóa đơn và danh sách mặt hàng cần tạo</param>
        /// <returns>Thông tin hóa đơn đã được tạo</returns>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Create)]
        public async Task<PurchaseInvoiceDto> CreateAsync(CreateUpdatePurchaseInvoiceDto input)
        {
            // Chuẩn hóa dữ liệu đầu vào
            input.InvoiceNumber = StringUtility.NormalizeString(input.InvoiceNumber);
            input.Notes = StringUtility.NormalizeStringNullable(input.Notes);

            // Tạo entity chính
            var purchaseInvoice = new PurchaseInvoice(
                GuidGenerator.Create(),
                input.InvoiceNumber,
                input.InvoiceDateId,
                input.Notes);

            // Thêm các mặt hàng sử dụng PurchaseInvoiceManager
            await _purchaseInvoiceManager.AddPurchaseInvoiceItemsAsync(purchaseInvoice, input.Items);

            // Tính tổng tiền hóa đơn
            purchaseInvoice.CalculateTotalAmount();

            // Lưu hóa đơn cùng với chi tiết mặt hàng
            var insertedEntity = await _purchaseInvoiceRepository.InsertAsync(purchaseInvoice);

            return ObjectMapper.Map<PurchaseInvoice, PurchaseInvoiceDto>(insertedEntity);
        }

        /// <summary>
        /// Cập nhật hóa đơn mua và các mặt hàng
        /// Xử lý thay đổi mặt hàng, tính toán lại tổng tiền và điều chỉnh stock
        /// </summary>
        /// <param name="id">ID của hóa đơn cần cập nhật</param>
        /// <param name="input">Thông tin hóa đơn và danh sách mặt hàng mới</param>
        /// <returns>Thông tin hóa đơn đã được cập nhật</returns>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Edit)]
        public async Task<PurchaseInvoiceDto> UpdateAsync(Guid id, CreateUpdatePurchaseInvoiceDto input)
        {
            // Chuẩn hóa dữ liệu đầu vào
            input.InvoiceNumber = StringUtility.NormalizeString(input.InvoiceNumber);
            input.Notes = StringUtility.NormalizeStringNullable(input.Notes);

            // Lấy entity hiện có cùng với chi tiết mặt hàng
            var existingEntity = await _purchaseInvoiceRepository.GetWithDetailsAsync(id);

            if (existingEntity is null)
                throw new EntityNotFoundException(typeof(PurchaseInvoice), id);

            // Kiểm tra có thể chỉnh sửa không
            existingEntity.ValidateCanEdit();

            // Cập nhật thông tin cơ bản
            existingEntity.InvoiceNumber = input.InvoiceNumber;
            existingEntity.InvoiceDateId = input.InvoiceDateId;
            existingEntity.Notes = input.Notes;

            // Cập nhật danh sách mặt hàng sử dụng PurchaseInvoiceManager
            await _purchaseInvoiceManager.UpdatePurchaseInvoiceItemsAsync(existingEntity, input.Items);

            // Tính lại tổng tiền
            existingEntity.CalculateTotalAmount();

            var updatedEntity = await _purchaseInvoiceRepository.UpdateAsync(existingEntity);

            return ObjectMapper.Map<PurchaseInvoice, PurchaseInvoiceDto>(updatedEntity);
        }

        /// <summary>
        /// Lấy danh sách hóa đơn mua có phân trang và lọc
        /// Hỗ trợ tìm kiếm theo số hóa đơn, lọc theo khoảng thời gian
        /// </summary>
        /// <param name="input">Tham số tìm kiếm, phân trang và bộ lọc</param>
        /// <returns>Danh sách hóa đơn mua đã được phân trang</returns>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Default)]
        public async Task<PagedResultDto<PurchaseInvoiceDto>> GetListAsync(GetPurchaseInvoiceListDto input)
        {
            if (string.IsNullOrEmpty(input.Sorting))
            {
                input.Sorting = "InvoiceDate.Date DESC";
            }

            var items = await _purchaseInvoiceRepository.GetListAsync(
                input.SkipCount,
                input.MaxResultCount,
                input.Sorting,
                input.Filter,
                input.FromDateId,
                input.ToDateId
            );

            var totalCount = await _purchaseInvoiceRepository.GetCountAsync(
                input.Filter,
                input.FromDateId,
                input.ToDateId
            );

            return new PagedResultDto<PurchaseInvoiceDto>(
                totalCount,
                ObjectMapper.Map<List<PurchaseInvoice>, List<PurchaseInvoiceDto>>(items)
            );
        }

        /// <summary>
        /// Xóa hóa đơn mua và xử lý stock nguyên liệu
        /// Kiểm tra quyền xóa và điều chỉnh stock nguyên liệu về trạng thái trước khi nhập
        /// </summary>
        /// <param name="id">ID của hóa đơn cần xóa</param>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Delete)]
        public async Task DeleteAsync(Guid id)
        {
            var entity = await _purchaseInvoiceRepository.GetWithDetailsAsync(id);
            
            // Xóa hóa đơn và xử lý stock sử dụng PurchaseInvoiceManager
            await _purchaseInvoiceManager.DeletePurchaseInvoiceAsync(entity);
            await _purchaseInvoiceRepository.DeleteAsync(entity);
        }


        /// <summary>
        /// Lấy thông tin nguyên liệu để sử dụng trong hóa đơn mua
        /// Bao gồm các đơn vị mua hàng active, giá cơ bản và thông tin nhà cung cấp
        /// </summary>
        /// <param name="ingredientId">ID của nguyên liệu cần lấy thông tin</param>
        /// <returns>Thông tin nguyên liệu phù hợp cho việc tạo hóa đơn mua</returns>
        [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
        public async Task<IngredientForPurchaseDto> GetIngredientForPurchaseAsync(Guid ingredientId)
        {
            var ingredient = await _ingredientDetailRepository.GetWithDetailsAsync(ingredientId);
            if (ingredient is null) 
                throw new EntityNotFoundException(typeof(Ingredient), ingredientId);
            
            var result = new IngredientForPurchaseDto
            {
                Id = ingredient.Id,
                Name = ingredient.Name,
                CostPerUnit = ingredient.CostPerUnit,
                SupplierInfo = ingredient.SupplierInfo,
                PurchaseUnits = ObjectMapper.Map<List<IngredientPurchaseUnit>, List<IngredientPurchaseUnitDto>>(
                    [.. ingredient.PurchaseUnits.Where(pu => pu.IsActive)])
            };
            
            return result;
        }

    }
}