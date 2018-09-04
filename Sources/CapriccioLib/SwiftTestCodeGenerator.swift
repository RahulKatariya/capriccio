//
//  SwiftTestFileGenerator.swift
//  CapriccioLib
//
//  Created by Franco on 03/09/2018.
//

import Gherkin
import Stencil

final class SwiftTestCodeGenerator {
    func generateSwiftTestCode(forFeature feature: Feature) -> String {
        let template = Template(templateString: templateString)
        
        do {
            return try template.render(["feature": feature.dictionary])
        }
        catch {
            fatalError("Template file rendering failed with error \(error)")
        }
    }
    
    /// Simple way of embedding the template given SPM doesn't support resources files yet
    let templateString = """
    final class {{ feature.className }} {
        {% for scenario in feature.scenarios %}
        {% if scenario.examples.count > 0 %}
        {% else %}
        func {{scenario.methodName }} {
            {% for step in scenario.steps%}
            {{ step.swiftText }}
            {% endfor %}
        }
        {% endif %}
        {% endfor %}
    }
    """
}