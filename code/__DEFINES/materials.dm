//Material Container Flags.
///If the container shows the amount of contained materials on examine.
#define MATCONTAINER_EXAMINE (1<<0)
///If the container cannot have materials inserted through attackby().
#define MATCONTAINER_NO_INSERT (1<<1)
///if the user can insert mats into the container despite the intent.
#define MATCONTAINER_ANY_INTENT (1<<2)
///if the user won't receive a warning when attacking the container with an unallowed item.
#define MATCONTAINER_SILENT (1<<3)

/// Applies the material color to the atom's color. Deprecated, use MATERIAL_GREYSCALE instead
#define MATERIAL_COLOR (1<<0)
/// Whether a prefix describing the material should be added to the name
#define MATERIAL_ADD_PREFIX (1<<1)
/// Whether a material's mechanical effects should apply to the atom
#define MATERIAL_NO_EFFECTS (1<<2)
/// Whether a material should affect the stats of the atom
#define MATERIAL_AFFECT_STATISTICS (1<<3)
/// Applies the material greyscale color to the atom's greyscale color.
#define MATERIAL_GREYSCALE (1<<4)

/// Wrapper for fetching material references. Exists exclusively so that people don't need to wrap everything in a list every time.
#define GET_MATERIAL_REF(material_type) GLOB.materials[material_type]
