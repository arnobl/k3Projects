/*
 * Creation : November 23, 2010
 * Licence  : EPL
 * Copyright: INRIA Rennes, Triskell
 * Authors  : Arnaud Blouin
 */
package fr.inria.triskell.kompren;

import fr.inria.triskell.k3.Aspect
import java.util.List
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EStructuralFeature
import org2.kermeta.kompren.slicer.SlicedProperty

@Aspect(className=typeof(EStructuralFeature)) class EStructuralFeatureAspectName {
	public def String getValidKermetaName() {
		var result = self.name
		
		if(self.name.equals("result") || self.name.equals("is") || self.name.equals("class") || self.name.equals("aspect") ||
			self.name.equals("inherits") || self.name.equals("do") || self.name.equals("value") || self.name.equals("if") ||
			self.name.equals("then") || self.name.equals("else") || self.name.equals("loop") || self.name.equals("until") ||
			self.name.equals("operation") || self.name.equals("method") || self.name.equals("end") || self.name.equals("reference") ||
			self.name.equals("attribute") || self.name.equals("package") || self.name.equals("using") || self.name.equals("require") ||
			self.name.equals("self") || self.name.equals("bag") || self.name.equals("Void") || self.name.equals("not") || self.name.equals("oset") ||
			self.name.equals("from") || self.name.equals("super") || self.name.equals("init") || self.name.equals("true") || self.name.equals("false") ||
			self.name.equals("var") || self.name.equals("raise") || self.name.equals("rescue") || self.name.equals("getter") || self.name.equals("pre") || self.name.equals("post") ||
			self.name.equals("setter") || self.name.equals("property") || self.name.equals("abstract") || self.name.equals("enumeration") || self.name.equals("metamodel") ||
			self.name.equals("set") || self.name.equals("inv") || self.name.equals("extern"))
			result = "~" + result
			
		return result
	}
}


@Aspect(className=typeof(EClassifier)) 
class EClassifierAspectName {
	public var List<SlicedProperty> outputFocusedRelations = null

	public def String getVarNameClassifier() {
		return self.getVarName(self.name, false)
	}


	public def String getVarName(String name, boolean withS) {
		var result = "the" + name
		if(withS) result = result + "s"
		return result
	}

	public def String getRequiredAttributeName() {
		return "required" + self.name + "s"
	}

	public def String getAddedAttributeName() {
		return "added" + self.name + "s"
	}
}
