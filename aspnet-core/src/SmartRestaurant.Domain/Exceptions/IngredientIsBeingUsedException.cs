using Volo.Abp;

namespace SmartRestaurant.Exceptions;

public class IngredientIsBeingUsedException : BusinessException
{
    public IngredientIsBeingUsedException(string ingredientName) 
        : base(SmartRestaurantDomainErrorCodes.Ingredients.IsBeingUsed)
    {
        WithData("IngredientName", ingredientName);
    }
}