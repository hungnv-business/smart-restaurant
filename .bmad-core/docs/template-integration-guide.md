# BMAD Template Integration Guide

## 🎯 Overview
This guide explains how the BMAD Scrum Master agent now integrates with the template system to automatically generate appropriate tasks and technical guidance based on story complexity.

## 🔧 How It Works

### Template Level Analysis
The Scrum Master agent now automatically analyzes story requirements and recommends the appropriate template level:

- **Level 1**: Simple CRUD entities (MenuCategory, UserRole, Settings)
- **Level 2**: Business logic entities (Order, Reservation, Payment)  
- **Level 3**: Interactive systems (Table Layout Kanban, Kitchen Dashboard)

### Enhanced Workflow
When you run `*draft` command, the Scrum Master will:

1. **Analyze Complexity**: Evaluate entity, UI, and technical requirements
2. **Recommend Template**: Choose Level 1, 2, or 3 based on analysis
3. **Generate Tasks**: Use template-specific task breakdown
4. **Include Guidance**: Add technical context from templates
5. **Estimate Points**: Provide story point range based on template level

## 📋 New Commands

### `*analyze-template`
Analyzes story requirements and recommends template level without creating a story.

**Usage:**
```
*analyze-template
```

The agent will ask for story requirements and provide:
- Template level recommendation
- Complexity analysis reasoning  
- Estimated story points range
- Template references

### Enhanced `*draft` 
Now includes automatic template integration in the story creation process.

## 🏗️ Template-Based Task Generation

### Level 1 Tasks (20-30 points)
- Standard CRUD operations
- ICrudAppService pattern
- PrimeNG Table + Dialog
- Basic testing strategy

### Level 2 Tasks (35-50 points)  
- Business logic implementation
- Custom application services
- Multi-step workflows
- Status management UI
- Enhanced testing

### Level 3 Tasks (55-80 points)
- Real-time infrastructure
- Advanced UI components
- Drag & drop functionality
- Performance optimization
- Comprehensive testing

## 📝 Story Template Enhancements

### New Template Metadata Section
Every story now includes:
- **Template Level**: Level 1, 2, or 3
- **Complexity Analysis**: Reasoning for template selection
- **Estimated Story Points**: Range based on template level
- **Template References**: Links to relevant template files

### Enhanced Dev Notes
- **Template-Specific Guidance**: Implementation patterns and best practices
- **Technical Context**: Framework requirements and dependencies
- **File Structure**: Naming conventions and organization
- **Testing Strategy**: Template-specific testing approaches

## 🧪 Testing the Integration

### Sample Story Analysis

#### Example 1: MenuCategory (Level 1)
```yaml
Entity: MenuCategory
Requirements: Basic CRUD for menu categories with name, description, display order
Analysis:
  Entity Complexity: Simple - only basic properties
  UI Complexity: Basic - list + form dialog sufficient  
  Technical Requirements: Standard - ICrudAppService pattern works
Recommended Level: Level 1
Estimated Points: 20-30
```

#### Example 2: Order Management (Level 2)
```yaml
Entity: Order
Requirements: Multi-step ordering process with status tracking and calculations
Analysis:
  Entity Complexity: Business - status changes, calculations, workflow
  UI Complexity: Workflow - stepper, status tracking needed
  Technical Requirements: Business - custom services, business logic
Recommended Level: Level 2
Estimated Points: 35-50
```

#### Example 3: Kitchen Dashboard (Level 3)
```yaml
Entity: KitchenOrder
Requirements: Real-time order tracking with drag & drop and live updates
Analysis:
  Entity Complexity: Complex - real-time state management
  UI Complexity: Interactive - drag & drop, real-time updates
  Technical Requirements: Advanced - SignalR, caching, performance critical
Recommended Level: Level 3
Estimated Points: 55-80
```

## 🔄 Migration Path

### For Existing Stories
1. Review current stories in `docs/stories/`
2. Identify their template level based on complexity
3. Add template metadata to existing story files
4. Update tasks to align with template patterns

### For New Stories
1. Use enhanced `*draft` command
2. Review template level recommendation
3. Adjust if needed based on specific requirements
4. Follow generated tasks with template guidance

## ⚡ Benefits

### For Scrum Masters
- **Consistent Planning**: Standardized task breakdown by complexity
- **Better Estimation**: Accurate story points based on template patterns
- **Quality Assurance**: Comprehensive task coverage for each complexity level

### for Developers  
- **Clear Context**: Template-specific guidance and patterns
- **Reduced Research**: All necessary technical info in story
- **Consistent Structure**: Predictable patterns across similar stories

### For Teams
- **Improved Velocity**: Better estimation and planning
- **Knowledge Sharing**: Reusable patterns and best practices
- **Quality Code**: Following established patterns and standards

## 📚 Template References

### Core Templates
- `templates/backend-template-level1.md` - Simple CRUD backend patterns
- `templates/backend-template-level2.md` - Business logic backend patterns  
- `templates/backend-template-level3.md` - Complex backend patterns
- `templates/frontend-template-level1.md` - Basic UI patterns
- `templates/frontend-template-level2.md` - Workflow UI patterns
- `templates/frontend-template-level3.md` - Interactive UI patterns

### BMAD Integration Files
- `.bmad-core/utils/template-level-analyzer.md` - Analysis logic
- `.bmad-core/templates/level1-tasks.yaml` - Level 1 task template
- `.bmad-core/templates/level2-tasks.yaml` - Level 2 task template  
- `.bmad-core/templates/level3-tasks.yaml` - Level 3 task template
- `.bmad-core/templates/story-tmpl.yaml` - Enhanced story template

## 🚀 Next Steps

1. **Test with Sample Stories**: Try `*analyze-template` with different story types
2. **Create New Story**: Use `*draft` to see full template integration
3. **Review Generated Tasks**: Verify template-specific tasks are appropriate
4. **Refine Templates**: Update templates based on real usage patterns
5. **Train Team**: Share this guide with development team

## 🐛 Troubleshooting

### Template Level Seems Wrong
- Review the complexity analysis in story metadata
- Consider manual override with justification
- Update template-level-analyzer.md criteria if needed

### Missing Tasks
- Check if task template covers all required scenarios
- Update corresponding levelX-tasks.yaml template
- Ensure acceptance criteria mapping is complete

### Estimation Issues
- Compare actual vs estimated story points over time
- Adjust story point ranges in templates if needed
- Consider story complexity factors unique to your project