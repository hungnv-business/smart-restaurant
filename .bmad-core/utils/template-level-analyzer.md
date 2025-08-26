# Template Level Analyzer Utility

## Purpose
This utility helps the Scrum Master agent analyze story requirements and recommend the appropriate template level (Level 1, 2, or 3) for consistent task generation and technical guidance.

## Template Level Decision Matrix

### 🔍 Analysis Criteria

#### Entity Complexity Assessment
- **Properties**: Simple fields vs. complex relationships vs. calculations
- **Business Logic**: None vs. workflows vs. core business rules
- **Data Flow**: CRUD only vs. multi-step processes vs. real-time updates

#### UI Complexity Assessment  
- **Interface**: Basic forms vs. multi-step wizards vs. interactive components
- **User Experience**: Simple interactions vs. workflow guidance vs. advanced UX
- **Real-time Needs**: Static data vs. status updates vs. live collaboration

#### Technical Requirements Assessment
- **Backend Pattern**: ICrudAppService vs. Custom Services vs. Complex Services
- **Frontend Pattern**: Table+Dialog vs. Stepper+Workflow vs. Drag&Drop+Real-time
- **Integration Needs**: None vs. API calls vs. SignalR+External systems

### 📋 Template Level Definitions

#### Level 1: Simple CRUD Template
**Indicators:**
- Entity có basic properties (name, description, isActive, displayOrder)
- Chỉ cần standard CRUD operations
- UI chỉ cần List + Form dialog
- Không có complex business logic
- Master data hoặc configuration data

**Examples:** MenuCategory, UserRole, LayoutSection, Settings, Tags
**Backend:** ICrudAppService pattern
**Frontend:** PrimeNG Table + Dialog Form
**Story Points Range:** 20-30 points

#### Level 2: Business Logic Template
**Indicators:**
- Entity có calculations, status changes, workflow
- Multi-step processes với business rules
- UI cần stepper, status tracking, conditional elements
- Có business validations và state transitions
- Transactional data với complex lifecycle

**Examples:** Order Management, Reservation Flow, Payment Process, Inventory Management
**Backend:** Custom IApplicationService với business methods
**Frontend:** Stepper + Status badges + Workflow UI
**Story Points Range:** 35-50 points

#### Level 3: Interactive Template
**Indicators:**
- Complex user interactions (drag & drop, real-time)
- Core business workflow control
- Advanced UX với visual editors
- Real-time collaboration features
- Performance-critical components

**Examples:** Table Layout Kanban, Kitchen Dashboard, Menu Builder, Real-time Reporting
**Backend:** Complex services + SignalR + Caching
**Frontend:** CDK Drag&Drop + Real-time + Advanced UX
**Story Points Range:** 55-80 points

## Decision Algorithm

### Step 1: Entity Analysis
```
IF entity has only basic properties (name, description, isActive)
   AND no calculations or complex relationships
   AND used primarily for configuration/master data
THEN consider Level 1

ELSE IF entity has business rules, calculations, or status changes
   AND involves multi-step processes or workflows
   AND requires business validations
THEN consider Level 2

ELSE IF entity controls core business workflows
   AND requires real-time updates or complex interactions
   AND involves performance-critical operations
THEN consider Level 3
```

### Step 2: UI Complexity Check
```
IF UI only needs basic list and form
   AND standard CRUD operations are sufficient
THEN confirm Level 1

ELSE IF UI needs multi-step wizards or status tracking
   AND workflow guidance is required
THEN confirm Level 2

ELSE IF UI needs drag & drop, real-time updates, or visual editors
   AND advanced user interactions are required
THEN confirm Level 3
```

### Step 3: Technical Requirements Validation
```
IF backend can use ICrudAppService
   AND frontend can use standard Table + Dialog pattern
THEN final recommendation: Level 1

ELSE IF backend needs custom business services
   AND frontend needs workflow components
THEN final recommendation: Level 2

ELSE IF backend needs SignalR, caching, complex services
   AND frontend needs advanced interactive components
THEN final recommendation: Level 3
```

## Usage Instructions for Scrum Master Agent

### Template Level Analysis Process
1. **Extract Story Requirements**: Read epic requirements and acceptance criteria
2. **Apply Decision Matrix**: Use the 3-step algorithm above
3. **Recommend Template Level**: Based on analysis results
4. **Generate Appropriate Tasks**: Use level-specific task templates
5. **Include Template References**: Link to relevant template documentation

### Analysis Output Format
```markdown
## Template Level Analysis

**Entity:** [EntityName]
**Recommended Level:** Level [X]

**Analysis Results:**
- **Entity Complexity:** [Simple/Business/Complex] - [reasoning]
- **UI Complexity:** [Basic/Workflow/Interactive] - [reasoning] 
- **Technical Requirements:** [Standard/Business/Advanced] - [reasoning]

**Template References:**
- Backend Template: [backend-template-level{X}.md](../../../templates/backend-template-level{X}.md)
- Frontend Template: [frontend-template-level{X}.md](../../../templates/frontend-template-level{X}.md)

**Estimated Story Points:** [range based on level]
```

### Integration with create-next-story Task
This analyzer should be called during Step 2 of create-next-story.md, right after gathering story requirements and before populating the story template.

### Error Handling
- If analysis results are unclear, default to Level 1 and note the uncertainty
- Allow manual override with justification
- Document any edge cases for future refinement

## Template Task Generation

### Level-Specific Task Sources
- **Level 1 Tasks:** Use `level1-tasks.yaml` template
- **Level 2 Tasks:** Use `level2-tasks.yaml` template  
- **Level 3 Tasks:** Use `level3-tasks.yaml` template

### Task Customization Variables
- `{EntityName}`: PascalCase entity name
- `{entityName}`: camelCase entity name
- `{entity-display-name}`: Vietnamese display name
- `{module}`: Module/feature folder name
- `{epic-num}`: Current epic number
- `{story-num}`: Current story number

## Continuous Improvement
Track template level accuracy over time:
- Compare estimated vs. actual story points
- Note any template level changes during development
- Update decision criteria based on lessons learned