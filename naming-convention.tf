module "naming_convention_purview" {
	source = "git::ssh://git@github.com/shin-akuma/infra-modules-terraform.git//modules/naming/conventions?ref=v0.1.4"

	location  = var.location
	prefixes  = var.naming_prefixes
	suffixes  = var.naming_suffixes
	separator = "-"
	iterator  = ""
}
