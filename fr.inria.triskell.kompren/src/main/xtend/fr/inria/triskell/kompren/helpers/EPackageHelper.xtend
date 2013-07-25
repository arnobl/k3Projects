/* $Id:$ 
 * Creation : January 5, 2010
 * Licence  : EPL 
 * Copyright: IRISA/INRIA
 * Authors  : ablouin
 */
package fr.inria.triskell.kompren.helpers

import fr.inria.triskell.k3.Aspect
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference

@Aspect(className=typeof(EPackage)) class EPackageAspectAll {
	public def List<EClass> getAllClasses(){
		return self.EClassifiers.filter(typeof(EClass)).toList
	}
	
	
	public def List<EReference> getAllReferences(){
		val result = self.getAllClasses.map[EStructuralFeatures.filter(typeof(EReference)).filter[!derived]].flatten.toList
		result.addAll(self.ESubpackages.map[getAllReferences].flatten.toList)
		return result
	} 
}
